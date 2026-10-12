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

resource "azurerm_resource_group" "data" {
  name     = "rg-data-prod"
  location = "westeurope"
}

# Delete lock on the resource group: everything inside inherits it. Reads and changes still work.
resource "azurerm_management_lock" "no_delete" {
  name       = "no-delete"
  scope      = azurerm_resource_group.data.id
  lock_level = "CanNotDelete"
  notes      = "Production data. Remove the lock deliberately before deleting anything."
}

# A Read-only lock blocks changes too, and some read operations that are POST calls (for example listing
# storage account keys). Use it rarely, on single resources:
# resource "azurerm_management_lock" "read_only" {
#   name       = "read-only"
#   scope      = azurerm_storage_account.archive.id
#   lock_level = "ReadOnly"
# }
