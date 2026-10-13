# Remote state in Azure Storage. Locking is built in: every plan/apply takes a lease on the state blob, and a
# second run waits (-lock-timeout) or fails instead of writing over the first one.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate00000"
    container_name       = "tfstate"
    key                  = "app/prod.tfstate" # one state per environment
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}
