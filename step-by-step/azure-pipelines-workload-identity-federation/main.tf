# Azure side of an Azure DevOps workload identity federation service connection (manual, managed identity).
# Same as identity.bicep. Run it twice, in the order the docs require:
#   1) terraform apply -var resource_group=rg-pinecone-shop
#      -> creates the identity, prints client_id, tenant_id, subscription_id
#   2) create the service connection, Keep as draft, copy Issuer and Subject identifier, then:
#      terraform apply -var resource_group=rg-pinecone-shop -var 'issuer=<Issuer>' -var 'subject=<Subject identifier>'

variable "resource_group" {
  description = "Existing resource group: the identity lives here and may deploy here"
  type        = string
}

variable "identity_name" {
  type    = string
  default = "id-pinecone-shop-deploy"
}

variable "issuer" {
  description = "Issuer from the draft service connection (new connections: https://login.microsoftonline.com/<tenant id>/v2.0). Empty on the first run."
  type        = string
  default     = ""
}

variable "subject" {
  description = "Subject identifier from the draft service connection. Empty on the first run."
  type        = string
  default     = ""
}

variable "role" {
  description = "Role on the resource group. Contributor is the docs example; prefer a narrower role."
  type        = string
  default     = "Contributor"
}

locals {
  federate = var.issuer != "" && var.subject != ""
}

data "azurerm_resource_group" "target" {
  name = var.resource_group
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "azurerm_user_assigned_identity" "deploy" {
  name                = var.identity_name
  location            = data.azurerm_resource_group.target.location
  resource_group_name = data.azurerm_resource_group.target.name
}

# One federated credential = one exact issuer + subject pair. Only this service connection can sign in.
resource "azurerm_federated_identity_credential" "devops" {
  count                     = local.federate ? 1 : 0
  name                      = "azure-devops-pinecone-prod"
  user_assigned_identity_id = azurerm_user_assigned_identity.deploy.id
  issuer                    = var.issuer
  subject                   = var.subject
  audience                  = ["api://AzureADTokenExchange"]
}

# Scope: this resource group only, not the subscription.
resource "azurerm_role_assignment" "deploy" {
  count                = local.federate ? 1 : 0
  scope                = data.azurerm_resource_group.target.id
  role_definition_name = var.role
  principal_id         = azurerm_user_assigned_identity.deploy.principal_id
  principal_type       = "ServicePrincipal"
}

# The four values the service connection asks for.
output "client_id" {
  value = azurerm_user_assigned_identity.deploy.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "subscription_name" {
  value = data.azurerm_subscription.current.display_name
}
