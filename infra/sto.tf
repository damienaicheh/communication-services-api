resource "azurerm_storage_account" "func_email" {
  name                     = format("stemail%s", local.resource_suffix_lowercase)
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_container" "func_email_deployment" {
  name                  = local.function_deployment_package_container
  storage_account_id    = azurerm_storage_account.func_email.id
  container_access_type = "private"
}

resource "azurerm_storage_account" "logs_email" {
  name                     = format("stmailog%s", substr(local.resource_suffix_lowercase, 0, 14)) # limit suffix to 14 chars
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_table" "email_logs" {
  name                  = "emaillogstore"
  storage_account_name  = azurerm_storage_account.logs_email.name
}


resource "azurerm_storage_account" "func_sms" {
  name                     = format("stsms%s", local.resource_suffix_lowercase)
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_container" "func_sms_deployment" {
  name                  = local.function_deployment_package_container
  storage_account_id    = azurerm_storage_account.func_sms.id
  container_access_type = "private"
}
