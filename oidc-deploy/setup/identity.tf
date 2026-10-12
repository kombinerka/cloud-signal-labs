# Same as create-identity.sh and identity.bicep, as Terraform.
#   terraform init && terraform apply -var github_repo=my-org/my-app -var target_resource_group=rg-app-prod
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

variable "github_repo" {
  description = "owner/repo on GitHub"
  type        = string
}

variable "environment_name" {
  description = "GitHub environment the deploy job runs in"
  type        = string
  default     = "production"
}

variable "target_resource_group" {
  description = "Resource group the identity may deploy to (and where it is created)"
  type        = string
}

variable "role" {
  description = "Role on the target resource group. Prefer a narrower one than Contributor."
  type        = string
  default     = "Contributor"
}

data "azurerm_resource_group" "target" {
  name = var.target_resource_group
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "deploy" {
  name                = "id-deploy-${var.environment_name}"
  location            = data.azurerm_resource_group.target.location
  resource_group_name = data.azurerm_resource_group.target.name
}

# One subject per credential: only jobs running in the named GitHub environment can sign in.
resource "azurerm_federated_identity_credential" "github" {
  name                      = "github-${var.environment_name}"
  user_assigned_identity_id = azurerm_user_assigned_identity.deploy.id
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_repo}:environment:${var.environment_name}"
  audience                  = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "deploy" {
  scope                = data.azurerm_resource_group.target.id
  role_definition_name = var.role
  principal_id         = azurerm_user_assigned_identity.deploy.principal_id
  principal_type       = "ServicePrincipal"
}

output "AZURE_CLIENT_ID" {
  value = azurerm_user_assigned_identity.deploy.client_id
}

output "AZURE_TENANT_ID" {
  value = data.azurerm_client_config.current.tenant_id
}

output "AZURE_SUBSCRIPTION_ID" {
  value = data.azurerm_client_config.current.subscription_id
}
