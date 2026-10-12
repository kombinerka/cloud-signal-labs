# Week one safety basics, Terraform version: Delete locks on production resource groups and a monthly budget.
#   terraform apply -var 'production_resource_groups=["rg-app-prod","rg-data-prod"]' -var 'budget_emails=["ops@example.com"]'
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

variable "production_resource_groups" {
  type = list(string)
}

variable "budget_amount" {
  description = "Monthly budget in the billing currency"
  type        = number
  default     = 2000
}

variable "budget_emails" {
  type = list(string)
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "prod" {
  for_each = toset(var.production_resource_groups)
  name     = each.value
}

resource "azurerm_management_lock" "no_delete" {
  for_each   = data.azurerm_resource_group.prod
  name       = "no-delete"
  scope      = each.value.id
  lock_level = "CanNotDelete"
  notes      = "Takeover: protect production until it is under code"
}

resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "budget-monthly"
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", plantimestamp())
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 80
    threshold_type = "Actual"
    contact_emails = var.budget_emails
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100
    threshold_type = "Forecasted"
    contact_emails = var.budget_emails
  }

  lifecycle {
    ignore_changes = [time_period] # the start date only matters on creation
  }
}
