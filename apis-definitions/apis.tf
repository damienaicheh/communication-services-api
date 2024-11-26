resource "azurerm_api_management_api" "emails" {
  name                = "emails-api"
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  revision            = "1"
  display_name        = "Emails"
  path                = "emails"
  protocols           = ["https"]
}

resource "azurerm_api_management_api_operation" "send_email" {
  operation_id        = "func-sendmail"
  api_name            = azurerm_api_management_api.emails.name
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  display_name        = "SendMail"
  method              = "POST"
  url_template        = "/SendMail"
}