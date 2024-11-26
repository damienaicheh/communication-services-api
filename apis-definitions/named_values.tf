# resource "azurerm_api_management_named_value" "func_sms_default_host_key" {
#   name                = local.function_name
#   resource_group_name = local.resource_group_name
#   api_management_name = local.api_management_name
#   display_name        = format("DefaultFunctionKey-%s", local.function_name)
#   value               = data.azurerm_function_app_host_keys.func.default_function_key
# }
