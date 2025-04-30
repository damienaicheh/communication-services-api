using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

class Program
{
    static async Task Main()
    {
        string filePath1 = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "TestFiles", "TextFile1.txt");
        string filePath2 = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "TestFiles", "TextFile2.txt");

        string base64Content1 = Convert.ToBase64String(await File.ReadAllBytesAsync(filePath1));
        string base64Content2 = Convert.ToBase64String(await File.ReadAllBytesAsync(filePath2));

        var payload = new
        {
            SenderAddress = "*.azurecomm.net",
            RecipientAddress = "*@domain.com",
                 // Replace with actual recipient
            Subject = "Test Email with Multiple Attachments",
            HtmlContent = "<p>This is a test email sent from local test app with multiple attachments.</p>",
            PlainTextContent = "This is a plain text fallback message.",  // Optional: can be same as subject or simple text
            Attachments = new List<object>
            {
                new { Base64 = base64Content1, FileName = "TextFile1.txt" },
                new { Base64 = base64Content2, FileName = "TextFile2.txt" }
            }
        };

        var json = JsonSerializer.Serialize(payload);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var functionUrl = "http://localhost:7071/api/SendMail";
        
        using var httpClient = new HttpClient();
        var response = await httpClient.PostAsync(functionUrl, content);

        string responseBody = await response.Content.ReadAsStringAsync();
        Console.WriteLine($"Response: {response.StatusCode} - {responseBody}");
    }
}
