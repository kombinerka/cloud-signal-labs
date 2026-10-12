// Same as create-identity.sh, as Bicep. Deploy into the resource group the identity may deploy to:
//   az deployment group create -g rg-app-prod -f identity.bicep -p githubRepo=my-org/my-app
@description('owner/repo on GitHub')
param githubRepo string

@description('GitHub environment the deploy job runs in')
param environmentName string = 'production'

param location string = resourceGroup().location

@description('Role to grant on this resource group. Default: Contributor. Prefer a narrower role.')
param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-deploy-${environmentName}'
  location: location
}

// One subject per credential: this one only trusts jobs that run in the named environment.
resource federated 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: identity
  name: 'github-${environmentName}'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubRepo}:environment:${environmentName}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, identity.id, roleDefinitionId)
  properties: {
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}

output clientId string = identity.properties.clientId
output tenantId string = tenant().tenantId
