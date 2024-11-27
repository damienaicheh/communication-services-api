using Azure;
using Azure.Communication.Email;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;
using System.Net;

namespace EmailAPI
{
    public class RequestBodyModel
    {
        public string? SenderAddress { get; set; }
        public string? RecipientAddress { get; set; }
        public string? Subject { get; set; }
        public string? HtmlContent { get; set; }
        public string? PlainTextContent { get; set; }
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
        public async Task<IActionResult> RunAsync([HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequest req)
        {
            _logger.LogInformation("Send mail triggered ...");
            var acsConnectionString = Environment.GetEnvironmentVariable("ACS_CONNECTION_STRING") ?? throw new ArgumentNullException("ACS_CONNECTION_STRING");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var data = JsonConvert.DeserializeObject<RequestBodyModel>(requestBody);
            string? senderAddress = data?.SenderAddress;
            string? recipientAddress = data?.RecipientAddress;
            string? subject = data?.Subject;
            string? htmlContent = data?.HtmlContent;
            string? plainTextContent = data?.PlainTextContent;

            if (string.IsNullOrEmpty(senderAddress) || string.IsNullOrEmpty(recipientAddress) || string.IsNullOrEmpty(subject) || string.IsNullOrEmpty(htmlContent) || string.IsNullOrEmpty(plainTextContent))
            {
                return new BadRequestObjectResult("Please pass a proper request body");
            }

            try
            {
                _logger.LogInformation($"Sending email from {senderAddress} to {recipientAddress} with subject {subject} ...");
                var emailClient = new EmailClient(acsConnectionString);

                EmailSendOperation emailSendOperation = emailClient.Send(
                    WaitUntil.Completed,
                    senderAddress: senderAddress,
                    recipientAddress: recipientAddress,
                    subject: subject,
                    htmlContent: htmlContent,
                    plainTextContent: plainTextContent);
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }

            return new OkObjectResult("Email sent successfully");
        }
    }
}
