# Pinecone shop infrastructure (AZ-401 episode 11) - Terraform version.
# Same resources as infra/main.bicep: plan + web app + staging slot + App Configuration.

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote state in Azure Storage (blob is locked while Terraform writes state).
  # Values are fictional; restrict network access to this storage account.
  backend "azurerm" {
    resource_group_name  = "rg-pinecone-tfstate"
    storage_account_name = "pineconetfstate"
    container_name       = "tfstate"
    key                  = "shop.prod.tfstate"
  }
}

provider "azurerm" {
  features {}
  # subscription_id comes from the ARM_SUBSCRIPTION_ID environment variable.
}

data "azurerm_resource_group" "shop" {
  name = var.resource_group_name
}

locals {
  app_name = "pinecone-shop-${var.environment_name}"
}

resource "azurerm_service_plan" "plan" {
  name                = "asp-${local.app_name}"
  resource_group_name = data.azurerm_resource_group.shop.name
  location            = data.azurerm_resource_group.shop.location
  os_type             = "Linux"
  sku_name            = var.plan_sku # slots need Standard or higher
}

resource "azurerm_linux_web_app" "web" {
  name                = local.app_name
  resource_group_name = data.azurerm_resource_group.shop.name
  location            = data.azurerm_resource_group.shop.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "22-lts"
    }
  }
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.web.id
  https_only     = true

  site_config {
    application_stack {
      node_version = "22-lts"
    }
  }
}

resource "azurerm_app_configuration" "config" {
  name                = "appcs-${local.app_name}"
  resource_group_name = data.azurerm_resource_group.shop.name
  location            = data.azurerm_resource_group.shop.location
  sku                 = "standard"
}

output "web_app_name" {
  value = azurerm_linux_web_app.web.name
}

output "app_config_endpoint" {
  value = azurerm_app_configuration.config.endpoint
}
