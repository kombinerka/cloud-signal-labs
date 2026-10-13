# After the upgrade, make the code match reality, or the next plan wants to change it back.
# azurerm: account_kind "StorageV2" and the access tier you chose.
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

resource "azurerm_storage_account" "legacy" {
  name                     = "stlegacy001"
  resource_group_name      = "rg-legacy"
  location                 = "westeurope"
  account_kind             = "StorageV2" # was "Storage" (GPv1)
  account_tier             = "Standard"
  account_replication_type = "GRS" # keep what you had
  access_tier              = "Hot" # or "Cool": decide, don't inherit a default by accident
  min_tls_version          = "TLS1_2"
}
