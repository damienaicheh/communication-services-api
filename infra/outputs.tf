output "resource_group_name" {
  value = local.resource_group_name
}

output "api_management_name" {
  value = azurerm_api_management.this.name
}

output "func_email_name" {
  value = azapi_resource.func_email.name
}

output "func_email_id" {
  value = azapi_resource.func_email.id
}

output "func_email_default_hostname" {
  value = azapi_resource.func_email.output.properties.hostNames[0]
}

output "func_sms_name" {
  value = azapi_resource.func_sms.name
}

output "func_sms_id" {
  value = azapi_resource.func_sms.id
}

output "func_sms_default_hostname" {
  value = azapi_resource.func_sms.output.properties.hostNames[0]
}
