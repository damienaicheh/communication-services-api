data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  count = var.resource_group_name != "" ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_function_app_host_keys" "func" {
  name                = local.function_name
  resource_group_name = local.resource_group_name

  depends_on = [
    azurerm_linux_function_app.this
  ]
}
