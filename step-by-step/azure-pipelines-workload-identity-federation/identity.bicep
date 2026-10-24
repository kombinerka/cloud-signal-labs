// Azure side of an Azure DevOps workload identity federation service connection (manual, managed identity).
// Run it twice, in the order the docs require:
//   1) before the service connection exists: creates the identity, prints its client ID
//        az deployment group create -g rg-pinecone-shop -f identity.bicep
//   2) after you saved the connection as a draft: adds the federated credential and the role
//        az deployment group create -g rg-pinecone-shop -f identity.bicep \
//          -p issuer='<Issuer from the draft>' subject='<Subject identifier from the draft>'
// Copy Issuer and Subject identifier from the draft connection. Don't type them: Azure DevOps generates them.

@description('Name of the user-assigned managed identity')
param identityName string = 'id-pinecone-shop-deploy'

param location string = resourceGroup().location

@description('Issuer from the draft service connection (new connections: https://login.microsoftonline.com/<tenant id>/v2.0). Empty on the first run.')
param issuer string = ''

@description('Subject identifier from the draft service connection. Empty on the first run.')
param subject string = ''

@description('Role on this resource group. Default: Contributor (the docs example). Prefer a narrower role.')
param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

var federate = !empty(issuer) && !empty(subject)

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

// One federated credential = one exact issuer + subject pair. Only this service connection can sign in.
resource federated 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = if (federate) {
  parent: identity
  name: 'azure-devops-pinecone-prod'
  properties: {
    issuer: issuer
    subject: subject
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

// Scope: this resource group only, not the subscription.
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (federate) {
  name: guid(resourceGroup().id, identity.id, roleDefinitionId)
  properties: {
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}

// The four values the service connection asks for.
output clientId string = identity.properties.clientId
output tenantId string = tenant().tenantId
output subscriptionId string = subscription().subscriptionId
output subscriptionName string = subscription().displayName
