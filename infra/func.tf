resource "azapi_resource" "func_email" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = local.resource_group_location
  name                      = format("func-email-%s", local.resource_suffix_kebabcase)
  parent_id                 = local.resource_group_id
  tags                      = local.tags
  body = {
    kind = "functionapp,linux",
    identity = {
      type : "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.plan_func_email.id,
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer",
            value = "${azurerm_storage_account.func_email.primary_blob_endpoint}${local.function_deployment_package_container}",
            authentication = {
              type = "SystemAssignedIdentity"
            }
          }
        },
        scaleAndConcurrency = {
          maximumInstanceCount = 100,
          instanceMemoryMB     = 2048
        },
        runtime = {
          name    = "dotnet-isolated",
          version = "8.0"
        }
      },
      siteConfig = {
        appSettings = [
          {
            name  = "AzureWebJobsStorage__accountName",
            value = azurerm_storage_account.func_email.name
          },
          {
            name  = "APPLICATIONINSIGHTS_AUTHENTICATION_STRING",
            value = "Authorization=AAD"
          },
          {
            name  = "APPLICATIONINSIGHTS_CONNECTION_STRING",
            value = format("InstrumentationKey=%s;IngestionEndpoint=https://%s.in.applicationinsights.azure.com/;LiveEndpoint=https://%s.livediagnostics.monitor.azure.com/", azurerm_application_insights.this.instrumentation_key, var.location, var.location)
          },
          {
            name = "ACS_CONNECTION_STRING"
            value = azurerm_communication_service.this.primary_connection_string
          }
        ]
      }
    }
  }
  depends_on = [
    azapi_resource.plan_func_email,
    azurerm_storage_account.func_email
  ]
}

resource "azapi_resource" "func_sms" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = local.resource_group_location
  name                      = format("func-sms-%s", local.resource_suffix_kebabcase)
  parent_id                 = local.resource_group_id
  tags                      = local.tags
  body = {
    kind = "functionapp,linux",
    identity = {
      type : "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.plan_func_sms.id,
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer",
            value = "${azurerm_storage_account.func_sms.primary_blob_endpoint}${local.function_deployment_package_container}",
            authentication = {
              type = "SystemAssignedIdentity"
            }
          }
        },
        scaleAndConcurrency = {
          maximumInstanceCount = 100,
          instanceMemoryMB     = 2048
        },
        runtime = {
          name    = "dotnet-isolated",
          version = "8.0"
        }
      },
      siteConfig = {
        appSettings = [
          {
            name  = "AzureWebJobsStorage__accountName",
            value = azurerm_storage_account.func_sms.name
          },
          {
            name  = "APPLICATIONINSIGHTS_AUTHENTICATION_STRING",
            value = "Authorization=AAD"
          },
          {
            name  = "APPLICATIONINSIGHTS_CONNECTION_STRING",
            value = format("InstrumentationKey=%s;IngestionEndpoint=https://%s.in.applicationinsights.azure.com/;LiveEndpoint=https://%s.livediagnostics.monitor.azure.com/", azurerm_application_insights.this.instrumentation_key, var.location, var.location)
          },
          {
            name = "ACS_CONNECTION_STRING"
            value = azurerm_communication_service.this.primary_connection_string
          },
          {
            name = "FROM_NUMBER"
            value = "CONTOSITA"
          }
        ]
      }
    }
  }
  depends_on = [
    azapi_resource.plan_func_sms,
    azurerm_storage_account.func_sms
  ]
}