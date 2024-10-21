resource "azurerm_api_management_api" "emails" {
  name                = "emails-api"
  resource_group_name = local.resource_group_name
  api_management_name = azurerm_api_management.this.name
  revision            = "1"
  display_name        = "Emails"
  path                = "emails"
  protocols           = ["https"]
}

resource "azurerm_api_management_api_operation" "send_email" {
  operation_id        = "func-sendmail"
  api_name            = azurerm_api_management_api.emails.name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = local.resource_group_name
  display_name        = "SendMail"
  method              = "POST"
  url_template        = "/SendMail"
}

resource "azurerm_api_management_api_operation_policy" "send_email" {
  api_name            = azurerm_api_management_api_operation.send_email.api_name
  api_management_name = azurerm_api_management_api_operation.send_email.api_management_name
  resource_group_name = azurerm_api_management_api_operation.send_email.resource_group_name
  operation_id        = azurerm_api_management_api_operation.send_email.operation_id

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <set-backend-service id="apim-generated-policy" backend-id="${local.function_name}" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML

}

resource "azurerm_api_management_named_value" "func_default_host_key" {
  name                = local.function_name
  resource_group_name = local.resource_group_name
  api_management_name = azurerm_api_management.this.name
  display_name        = format("DefaultFunctionKey-%s", local.function_name)
  value               = data.azurerm_function_app_host_keys.func.default_function_key
}

resource "azurerm_api_management_backend" "func" {
  name                = azurerm_linux_function_app.this.name
  description         = azurerm_linux_function_app.this.name
  resource_id         = "https://management.azure.com${azurerm_linux_function_app.this.id}"
  resource_group_name = local.resource_group_name
  api_management_name = azurerm_api_management.this.name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.this.default_hostname}/api"

  credentials {
    certificate = []
    header = {
      "x-functions-key" = data.azurerm_function_app_host_keys.func.default_function_key
    }
    query = {}
  }
}
