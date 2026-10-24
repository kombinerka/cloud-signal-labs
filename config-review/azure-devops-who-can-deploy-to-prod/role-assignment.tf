# Pinecone shop: the same scoped role assignment as role-assignment.bicep.

variable "resource_group_name" {
  description = "The only resource group the deploy identity may change"
  type        = string
  default     = "rg-pinecone-shop"
}

variable "principal_id" {
  description = "Object (principal) ID of the deploy identity (service principal or user-assigned managed identity)"
  type        = string
}

data "azurerm_resource_group" "shop" {
  name = var.resource_group_name
}

# Contributor on one resource group, not on the subscription.
# Contributor cannot assign roles, so the identity cannot widen its own access.
resource "azurerm_role_assignment" "deploy_contributor" {
  scope                = data.azurerm_resource_group.shop.id
  role_definition_name = "Contributor"
  principal_id         = var.principal_id
  principal_type       = "ServicePrincipal"
  description          = "Pinecone deploy identity: Contributor on rg-pinecone-shop only"
}

output "scope" {
  value = azurerm_role_assignment.deploy_contributor.scope
}
