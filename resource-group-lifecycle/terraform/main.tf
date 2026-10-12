# Group by lifecycle: what is created and deleted together lives together.
# The test environment is safe to delete as a whole; the production data has its own group and a Delete lock.
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

variable "location" {
  type    = string
  default = "westeurope"
}

# Deleted together after every test cycle.
resource "azurerm_resource_group" "test" {
  name     = "rg-shop-test"
  location = var.location
  tags     = { lifecycle = "ephemeral", environment = "test" }
}

# Lives for years, independent of any test cycle.
resource "azurerm_resource_group" "data_prod" {
  name     = "rg-shop-data-prod"
  location = var.location
  tags     = { lifecycle = "long-lived", environment = "prod" }
}

resource "azurerm_management_lock" "data_prod" {
  name       = "no-delete"
  scope      = azurerm_resource_group.data_prod.id
  lock_level = "CanNotDelete"
  notes      = "Production data. A delete of this group stops here."
}
