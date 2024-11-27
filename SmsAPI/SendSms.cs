using Azure;
using Azure.Communication;
using Azure.Communication.Sms;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;
using System.Net;

namespace SmsAPI
{
    public class RequestBodyModel
    {
        public string? FromNumber { get; set; }
        public string? ToNumber { get; set; }
        public string? Message { get; set; }
    }

    public class SendSms
    {
        private readonly ILogger<SendSms> _logger;

        public SendSms(ILogger<SendSms> logger)
        {
            _logger = logger;
        }

        [Function(nameof(SendSms))]
        [OpenApiOperation(operationId: nameof(SendSms), tags: new[] { "Send Sms" }, Summary = "Send Sms", Description = "Send Sms")]
        [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
        [OpenApiRequestBody("application/json", typeof(RequestBodyModel), Required = true,
           Description = "JSON request body containing { SenderAddress, RecipientAddress, Subject, HtmlContent, PlainTextContent }")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
        public async Task<IActionResult> RunAsync([HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequest req)
        {
            _logger.LogInformation("Send Sms triggered ...");
            var acsConnectionString = Environment.GetEnvironmentVariable("ACS_CONNECTION_STRING") ?? throw new ArgumentNullException("ACS_CONNECTION_STRING");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var data = JsonConvert.DeserializeObject<RequestBodyModel>(requestBody);
            string? fromNumber = data?.FromNumber;
            string? toNumber = data?.ToNumber;
            string? message = data?.Message;

            if (string.IsNullOrEmpty(fromNumber) || string.IsNullOrEmpty(toNumber) || string.IsNullOrEmpty(message))
            {
                return new BadRequestObjectResult("Please pass a proper request body");
            }

            try
            {
                _logger.LogInformation($"Sending Sms from {fromNumber} to {toNumber} with message {message} ...");

                var smsClient = new SmsClient(acsConnectionString);
                smsClient.Send(
                    from: fromNumber,
                    to: toNumber,
                    message: message
                );
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }

            return new OkObjectResult("Sms sent successfully");
        }
    }
}