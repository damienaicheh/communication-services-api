using System.Net;
using Azure;
using Azure.Communication.Email;
using Azure.Data.Tables;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.OpenApi.Models;

namespace EmailAPI
{
    public class RequestBodyModel
    {
        [JsonPropertyName("SenderAddress")]
        public string? SenderAddress { get; set; }

        [JsonPropertyName("RecipientAddress")]
        public string? RecipientAddress { get; set; } 

        [JsonPropertyName("Subject")]
        public string? Subject { get; set; }

        [JsonPropertyName("HtmlContent")]
        public string? HtmlContent { get; set; }

        [JsonPropertyName("PlainTextContent")]
        public string? PlainTextContent { get; set; }

        [JsonPropertyName("Attachments")]
        public List<AttachmentRequest> Attachments { get; set; } = new();
    }

    public class AttachmentRequest
    {
        [JsonPropertyName("base64")]
        public string? Base64 { get; set; }

        [JsonPropertyName("fileName")]
        public string? FileName { get; set; } 
    }

    public class EmailLogEntity : ITableEntity
    {
        public string PartitionKey { get; set; } = "EmailLog";
        public string RowKey { get; set; } = Guid.NewGuid().ToString();
        public string To { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string ErrorMessage { get; set; } = string.Empty;
        public DateTimeOffset? Timestamp { get; set; } = DateTimeOffset.UtcNow;
        public ETag ETag { get; set; } = ETag.All;
    }

    public class SendMail
    {
        private readonly ILogger<SendMail> _logger;

        public SendMail(ILogger<SendMail> logger)
        {
            _logger = logger;
        }

        [Function(nameof(SendMail))]
        [OpenApiOperation(operationId: nameof(SendMail), tags: new[] { "Send Mail" }, Summary = "Send Mail", Description = "Send Mail")]
        [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
        [OpenApiRequestBody("application/json", typeof(RequestBodyModel), Required = true,
           Description = "JSON request body containing { SenderAddress, RecipientAddress, Subject, HtmlContent, PlainTextContent }")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]

        public async Task<HttpResponseData> RunAsync(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
            FunctionContext context)
        {
            _logger.LogInformation("Send mail triggered ...");
            var acsConnectionString = Environment.GetEnvironmentVariable("ACS_CONNECTION_STRING") ?? throw new ArgumentNullException("ACS_CONNECTION_STRING");
            var logsStorageConnectionstring = Environment.GetEnvironmentVariable("Logs_STORAGE_CONNECTION_STRING") ?? throw new ArgumentNullException("Logs_STORAGE_CONNECTION_STRING");

            var response = req.CreateResponse();
            RequestBodyModel? emailRequest = null;
            try
            {
                var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                _logger.LogInformation($"Raw Request Body: {requestBody}");
                 emailRequest = JsonSerializer.Deserialize<RequestBodyModel>(requestBody) ?? new RequestBodyModel();

                if (string.IsNullOrWhiteSpace(emailRequest.RecipientAddress))
                    throw new ArgumentException("Recipient address ('to') is required.");

                if (string.IsNullOrWhiteSpace(emailRequest.SenderAddress))
                    throw new ArgumentException("Sender address ('to') is required.");

                var emailClient = new EmailClient(acsConnectionString);

                var recipient = new EmailAddress(emailRequest.RecipientAddress);
                var recipients = new EmailRecipients(new List<EmailAddress> { recipient });

                var content = new EmailContent(emailRequest.Subject)
                {
                    Html = emailRequest.HtmlContent,
                    PlainText = string.IsNullOrWhiteSpace(emailRequest.PlainTextContent) ? emailRequest.Subject : null
                };

                var message = new EmailMessage(emailRequest.SenderAddress, recipients, content);

                foreach (var att in emailRequest.Attachments)
                {
                    if (!string.IsNullOrWhiteSpace(att.Base64) && !string.IsNullOrWhiteSpace(att.FileName))
                    {
                        byte[] data = Convert.FromBase64String(att.Base64);
                        message.Attachments.Add(new EmailAttachment(
                            att.FileName,
                            "application/octet-stream",
                            new BinaryData(data)));
                    }
                }

                var operation = await emailClient.SendAsync(Azure.WaitUntil.Completed, message);
                var result = operation.Value;
                if (result.Status == EmailSendStatus.Succeeded)
                {
                    await LogToTableStorageAsync(logsStorageConnectionstring, emailRequest, "Success", string.Empty);
                    response.StatusCode = HttpStatusCode.OK;
                    await response.WriteStringAsync("Email sent successfully.");
                }
                else
                {
                    throw new Exception($"Email failed with status: {result.Status}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending email to {Recipient}", emailRequest?.RecipientAddress?? "N/A");

                await LogToTableStorageAsync(
                    logsStorageConnectionstring,
                    new RequestBodyModel
                    {
                        RecipientAddress = emailRequest?.RecipientAddress ?? "N/A",
                        Subject = emailRequest?.Subject ?? "N/A"
                    },
                    "Failed",
                    ex.Message);

                response.StatusCode = HttpStatusCode.InternalServerError;
                await response.WriteStringAsync($"Failed to send email: {ex.Message}");
            }

            return response;
        }

        private async Task LogToTableStorageAsync(string connection, RequestBodyModel request, string status, string errorMsg)
        {
            try
            {
                var tableClient = new TableClient(connection, "emaillogstore");
                await tableClient.CreateIfNotExistsAsync();

                if (!string.IsNullOrWhiteSpace(request.RecipientAddress) && !string.IsNullOrWhiteSpace(request.Subject))
                {
                    var log = new EmailLogEntity
                    {
                        To = request.RecipientAddress,
                        Subject = request.Subject,
                        Status = status,
                        ErrorMessage = errorMsg
                    };

                    await tableClient.AddEntityAsync(log);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to log to Table Storage for recipient: {Recipient}, subject: {Subject}",
                    request?.RecipientAddress ?? "N/A",
                    request?.Subject ?? "N/A");
            }
        }
    }
}

