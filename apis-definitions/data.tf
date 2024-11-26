data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "./../infra/terraform.tfstate"
  }
}

data "azurerm_function_app_host_keys" "func_email" {
  name                = local.func_email_name
  resource_group_name = local.resource_group_name
}

# data "azurerm_function_app_host_keys" "func_sms" {
#   name                = local.func_sms_name
#   resource_group_name = local.resource_group_name
# }
