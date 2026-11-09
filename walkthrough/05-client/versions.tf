terraform {
  required_version = ">= 1.16.6, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.13.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# The Oracle database API accepts storage in GB. AzureRM 4.81.0 only exposes TB.
# Keep the small database allocation explicit using AzAPI, still within Terraform.
provider "azapi" {
  subscription_id = var.subscription_id
}
