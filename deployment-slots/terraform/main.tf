# App Service with a staging slot. Slots need the Standard tier or higher.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "name" {
  description = "Globally unique web app name"
  type        = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azurerm_resource_group" "app" {
  name     = "rg-${var.name}"
  location = var.location
}

resource "azurerm_service_plan" "app" {
  name                = "asp-${var.name}"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "app" {
  name                = var.name
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  service_plan_id     = azurerm_service_plan.app.id
  https_only          = true

  site_config {
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
  }
}

# Blue-green: deploy here, test, swap. Canary: route a percentage of production traffic here.
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.app.id
  https_only     = true

  site_config {
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
  }
}

# Traffic routing changes during a release, so it is set by the release scripts (canary.sh),
# not here; otherwise every terraform apply would reset it.
