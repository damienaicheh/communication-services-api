resource "azapi_resource" "plan_func_email" {
  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  name                      = format("asp-email-%s", local.resource_suffix_kebabcase)
  location                  = local.resource_group_location
  parent_id                 = local.resource_group_id
  schema_validation_enabled = false
  body = {
    kind = "functionapp",
    sku = {
      tier = "FlexConsumption",
      name = "FC1"
    },
    properties = {
      reserved = true
    }
  }
  tags = local.tags
}

resource "azapi_resource" "plan_func_sms" {
  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  name                      = format("asp-sms-%s", local.resource_suffix_kebabcase)
  location                  = local.resource_group_location
  parent_id                 = local.resource_group_id
  schema_validation_enabled = false
  body = {
    kind = "functionapp",
    sku = {
      tier = "FlexConsumption",
      name = "FC1"
    },
    properties = {
      reserved = true
    }
  }
  tags = local.tags
}