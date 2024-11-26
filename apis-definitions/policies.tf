resource "azurerm_api_management_api_operation_policy" "send_email" {
  api_name            = azurerm_api_management_api_operation.send_email.api_name
  api_management_name = azurerm_api_management_api_operation.send_email.api_management_name
  resource_group_name = azurerm_api_management_api_operation.send_email.resource_group_name
  operation_id        = azurerm_api_management_api_operation.send_email.operation_id

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <set-backend-service id="apim-generated-policy" backend-id="${local.func_email_name}" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML

}