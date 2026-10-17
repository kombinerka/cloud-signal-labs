# Pinecone shop: the same vault and role assignment as keyvault.bicep.

variable "resource_group_name" {
  type    = string
  default = "rg-pinecone-shop"
}

variable "deploy_principal_id" {
  description = "principalId of id-pinecone-deploy (user-assigned managed identity)"
  type        = string
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "shop" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "shop" {
  name                       = "kv-pinecone-shop"
  location                   = data.azurerm_resource_group.shop.location
  resource_group_name        = data.azurerm_resource_group.shop.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true # Azure RBAC instead of access policies
  purge_protection_enabled   = true
}

# Key Vault Secrets User: read secret contents, nothing else.
resource "azurerm_role_assignment" "deploy_secrets_user" {
  scope                = azurerm_key_vault.shop.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.deploy_principal_id
  principal_type       = "ServicePrincipal"
}

output "vault_uri" {
  value = azurerm_key_vault.shop.vault_uri
}
