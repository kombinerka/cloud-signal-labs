# Pinecone shop: the same secretless identity as identity.bicep, in Terraform.

variable "resource_group_name" {
  type    = string
  default = "rg-pinecone-shop"
}

variable "github_repo" {
  description = "GitHub owner/repository that may deploy"
  type        = string
  default     = "pinecone-gear/shop"
}

variable "ado_issuer" {
  description = "Issuer shown on the Azure DevOps service connection screen"
  type        = string
}

variable "ado_subject" {
  description = "Subject identifier shown on the Azure DevOps service connection screen"
  type        = string
}

data "azurerm_resource_group" "shop" {
  name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "deploy" {
  name                = "id-pinecone-deploy"
  resource_group_name = data.azurerm_resource_group.shop.name
  location            = data.azurerm_resource_group.shop.location
}

# GitHub Actions: issuer + subject + audience must match the token exactly.
resource "azurerm_federated_identity_credential" "github_production" {
  name                      = "github-production"
  user_assigned_identity_id = azurerm_user_assigned_identity.deploy.id
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_repo}:environment:production"
  audience                  = ["api://AzureADTokenExchange"]
}

# Azure DevOps service connection (Managed identity option).
resource "azurerm_federated_identity_credential" "ado_prod" {
  name                      = "ado-pinecone-prod"
  user_assigned_identity_id = azurerm_user_assigned_identity.deploy.id
  issuer                    = var.ado_issuer
  subject                   = var.ado_subject
  audience                  = ["api://AzureADTokenExchange"]

  # create credentials one after another, not in parallel
  depends_on = [azurerm_federated_identity_credential.github_production]
}

# Least privilege: Contributor on this resource group only.
resource "azurerm_role_assignment" "deploy_contributor" {
  scope                = data.azurerm_resource_group.shop.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.deploy.principal_id
  principal_type       = "ServicePrincipal"
}

output "client_id" {
  value = azurerm_user_assigned_identity.deploy.client_id
}
