# Storage for backups with a lifecycle policy: hot -> cool after 30 days -> archive after 90 -> delete after 400.
# Archive is cheapest, but offline: reading needs a rehydration that can take up to 15 hours (see ../rehydrate.sh).
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
  description = "Globally unique storage account name"
  type        = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azurerm_resource_group" "backup" {
  name     = "rg-backup"
  location = var.location
}

resource "azurerm_storage_account" "backup" {
  name                            = var.name
  resource_group_name             = azurerm_resource_group.backup.name
  location                        = azurerm_resource_group.backup.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS" # archive is supported on LRS, GRS and RA-GRS, not on ZRS/GZRS
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "backups" {
  name               = "backups"
  storage_account_id = azurerm_storage_account.backup.id
}

resource "azurerm_storage_management_policy" "tiers" {
  storage_account_id = azurerm_storage_account.backup.id

  rule {
    name    = "backups-to-archive"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["backups/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        # Archive has a 180-day minimum: deleting at day 400 means 310 days in archive, so no early-deletion fee.
        delete_after_days_since_modification_greater_than = 400
      }
    }
  }
}
