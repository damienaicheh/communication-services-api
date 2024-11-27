resource "azurerm_api_management_backend" "func_email" {
  name                = local.func_email_name
  description         = local.func_email_name
  resource_id         = "https://management.azure.com${local.func_email_id}"
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  protocol            = "http"
  url                 = "https://${local.func_email_default_hostname}/api"

  credentials {
    certificate = []
    header = {
      "x-functions-key" = data.azurerm_function_app_host_keys.func_email.default_function_key
    }
    query = {}
  }
}

resource "azurerm_api_management_backend" "func_sms" {
  name                = local.func_sms_name
  description         = local.func_sms_name
  resource_id         = "https://management.azure.com${local.func_sms_id}"
  resource_group_name = local.resource_group_name
  api_management_name = local.api_management_name
  protocol            = "http"
  url                 = "https://${local.func_sms_default_hostname}/api"

  credentials {
    certificate = []
    header = {
      "x-functions-key" = data.azurerm_function_app_host_keys.func_sms.default_function_key
    }
    query = {}
  }
}