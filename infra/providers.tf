terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.11.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "2.0.1"
    }
  }

  backend "local" {}
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
