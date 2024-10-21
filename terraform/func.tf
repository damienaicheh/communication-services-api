resource "azurerm_service_plan" "this" {
  name                = format("asp-%s", local.resource_suffix_kebabcase)
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.tags
}

resource "azurerm_linux_function_app" "this" {
  name                = local.function_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  tags                = local.tags

  storage_account_name                           = azurerm_storage_account.func.name
  storage_account_access_key                     = azurerm_storage_account.func.primary_access_key
  service_plan_id                                = azurerm_service_plan.this.id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }

  app_settings = {
    "ACS_CONNECTION_STRING" = azurerm_communication_service.this.primary_connection_string
  }
}
