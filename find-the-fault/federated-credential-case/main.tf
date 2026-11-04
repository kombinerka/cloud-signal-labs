# Find the Fault #2: federated identity credentials, spelled exactly (case included).
# Pinecone (fictional). Validated with terraform validate, not deployed.

variable "resource_group_name" {
  type    = string
  default = "rg-pinecone-shop"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "identity_name" {
  type    = string
  default = "id-pinecone-shop-gh"
}

variable "github_org" {
  description = "GitHub organization, exactly as GitHub shows it (case matters)."
  type        = string
  default     = "pinecone-gear"
}

variable "github_repo" {
  description = "GitHub repository, exactly as GitHub shows it (case matters)."
  type        = string
  default     = "shop"
}

variable "github_environment" {
  description = "GitHub environment name, spelled exactly as the workflow spells it (case matters)."
  type        = string
  default     = "Production"
}

variable "pipelines_issuer" {
  description = "Azure Pipelines: Issuer copied from the service connection. Empty = no Pipelines credential."
  type        = string
  default     = ""
}

variable "pipelines_subject" {
  description = "Azure Pipelines: Subject identifier copied from the service connection."
  type        = string
  default     = ""
}

locals {
  audience      = "api://AzureADTokenExchange"
  github_issuer = "https://token.actions.githubusercontent.com"
  # Format from the docs: repo:<Organization/Repository>:environment:<Name>
  github_subject = "repo:${var.github_org}/${var.github_repo}:environment:${var.github_environment}"
}

resource "azurerm_user_assigned_identity" "shop" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "github" {
  name                = "github-shop-${lower(var.github_environment)}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.shop.id
  audience            = [local.audience]
  issuer              = local.github_issuer
  subject             = local.github_subject
}

resource "azurerm_federated_identity_credential" "pipelines" {
  count               = var.pipelines_issuer != "" && var.pipelines_subject != "" ? 1 : 0
  name                = "ado-pinecone-prod"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.shop.id
  audience            = [local.audience]
  issuer              = var.pipelines_issuer
  subject             = var.pipelines_subject

  # Create credentials on one identity one after the other (sequential, to be safe).
  depends_on = [azurerm_federated_identity_credential.github]
}

output "client_id" {
  value = azurerm_user_assigned_identity.shop.client_id
}

output "github_subject" {
  value = local.github_subject
}
