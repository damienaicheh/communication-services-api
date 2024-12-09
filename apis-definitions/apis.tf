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

resource "azurerm_api_management_api" "sms" {
  name                = "sms-api"
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  revision            = "1"
  display_name        = "Sms"
  path                = "sms"
  protocols           = ["https"]
}

resource "azurerm_api_management_api_operation" "send_sms" {
  operation_id        = "func-sms"
  api_name            = azurerm_api_management_api.sms.name
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  display_name        = "SendSms"
  method              = "POST"
  url_template        = "/SendSms"
}