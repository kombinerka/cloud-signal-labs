# Auto-shutdown for a dev/test VM. It stops the VM from Azure, so it ends up "Stopped (deallocated)"
# and compute billing stops (disks and static public IPs are still billed).
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

variable "vm_id" {
  description = "Resource ID of the VM"
  type        = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "evening" {
  virtual_machine_id    = var.vm_id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled = false
  }
}
