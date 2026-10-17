// Pinecone shop: a user-assigned managed identity that GitHub Actions and an
// Azure DevOps service connection can use without any secret.
// Deploy at resource group scope:
//   az deployment group create -g rg-pinecone-shop -f identity.bicep \
//     -p adoIssuer=<issuer> adoSubject=<subject identifier>
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param identityName string = 'id-pinecone-deploy'

@description('GitHub owner/repository and environment that may deploy')
param githubRepo string = 'pinecone-gear/shop'
param githubEnvironment string = 'production'

@description('Issuer shown on the Azure DevOps service connection screen')
param adoIssuer string

@description('Subject identifier shown on the Azure DevOps service connection screen')
param adoSubject string

resource deployIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

// GitHub Actions: issuer + subject + audience must match the token exactly.
resource githubFic 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: deployIdentity
  name: 'github-production'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubRepo}:environment:${githubEnvironment}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

// Azure DevOps service connection (Managed identity option).
// Credentials are created one after another: parallel creation can fail with 409.
resource adoFic 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: deployIdentity
  name: 'ado-pinecone-prod'
  properties: {
    issuer: adoIssuer
    subject: adoSubject
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
  dependsOn: [
    githubFic
  ]
}

// Least privilege: Contributor on this resource group only.
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, deployIdentity.id, contributorRoleId)
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: deployIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output clientId string = deployIdentity.properties.clientId
output principalId string = deployIdentity.properties.principalId
