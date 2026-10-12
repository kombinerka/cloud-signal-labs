# Alternative: write the resource group's tag onto the resources themselves with Azure Policy
# ("Inherit a tag from the resource group if missing", built-in, modify effect).
# Unlike the Cost Management setting this CHANGES resources (adds tags), so the assignment needs an identity
# with the role the policy definition asks for (Contributor).
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

variable "tag_name" {
  type    = string
  default = "costCenter"
}

variable "location" {
  description = "Location of the assignment's managed identity"
  type        = string
  default     = "westeurope"
}

data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "inherit_tag" {
  name                 = "inherit-${lower(var.tag_name)}-from-rg"
  display_name         = "Inherit ${var.tag_name} from the resource group if missing"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName = { value = var.tag_name }
  })
}

resource "azurerm_role_assignment" "policy_identity" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.inherit_tag.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# New and updated resources get the tag automatically. Existing ones need a remediation task:
resource "azurerm_subscription_policy_remediation" "existing" {
  name                 = "inherit-${lower(var.tag_name)}-existing"
  subscription_id      = data.azurerm_subscription.current.id
  policy_assignment_id = azurerm_subscription_policy_assignment.inherit_tag.id
  depends_on           = [azurerm_role_assignment.policy_identity]
}
