// Email
{
    "SenderAddress": "*.azurecomm.net",
    "RecipientAddress": "*@domain.com",
    "Subject": "Test Email",
    "HtmlContent": "<html><h1>Hello world via email.</h1l></html>",
    "PlainTextContent": "Hello world via email.",
    "Attachments": [
        {
          "Base64": "77u/SGVsbG8gdGhpcyBpcyBhdHRhY2htZW50IEE=",
          "FileName": "TextFile1.txt"
        }  
    ]
}

// SMS
{
    "FromNumber": "CONTOSO", // Optional
    "ToNumber": "+24523456789",
    "Message": "Test SMS",
}
