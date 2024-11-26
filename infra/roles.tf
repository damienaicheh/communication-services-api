resource "azurerm_role_assignment" "func_email_deployment_storage_blob_data_owner" {
  scope                = azurerm_storage_account.func_email.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azapi_resource.func_email.output.identity.principalId
}

resource "azurerm_role_assignment" "func_sms_deployment_storage_blob_data_owner" {
  scope                = azurerm_storage_account.func_sms.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azapi_resource.func_sms.output.identity.principalId
}
