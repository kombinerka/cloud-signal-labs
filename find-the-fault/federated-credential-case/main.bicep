// Find the Fault #2: federated identity credentials, spelled exactly (case included).
// Pinecone (fictional). Validated with bicep build, not deployed.
// One user-assigned managed identity with:
//   1. a federated credential for the GitHub Actions job in environment `githubEnvironment`
//   2. optionally, a federated credential for an Azure Pipelines service connection
//      (issuer + subject copied from Azure DevOps, never typed)

@description('Region for the managed identity.')
param location string = resourceGroup().location

@description('Name of the user-assigned managed identity.')
param identityName string = 'id-pinecone-shop-gh'

@description('GitHub organization, exactly as GitHub shows it (case matters).')
param githubOrg string = 'pinecone-gear'

@description('GitHub repository, exactly as GitHub shows it (case matters).')
param githubRepo string = 'shop'

@description('GitHub environment name, spelled exactly as the workflow spells it (case matters).')
param githubEnvironment string = 'Production'

@description('Azure Pipelines: Issuer copied from the service connection. Empty = no Pipelines credential.')
param pipelinesIssuer string = ''

@description('Azure Pipelines: Subject identifier copied from the service connection.')
param pipelinesSubject string = ''

var githubIssuer = 'https://token.actions.githubusercontent.com'
var audience = 'api://AzureADTokenExchange'
// Format from the docs: repo:<Organization/Repository>:environment:<Name>
var githubSubject = 'repo:${githubOrg}/${githubRepo}:environment:${githubEnvironment}'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource ficGithub 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: identity
  name: 'github-shop-${toLower(githubEnvironment)}'
  properties: {
    issuer: githubIssuer
    subject: githubSubject
    audiences: [
      audience
    ]
  }
}

// Create credentials on one identity one after the other (sequential, to be safe).
resource ficPipelines 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = if (!empty(pipelinesIssuer) && !empty(pipelinesSubject)) {
  parent: identity
  name: 'ado-pinecone-prod'
  dependsOn: [
    ficGithub
  ]
  properties: {
    issuer: pipelinesIssuer
    subject: pipelinesSubject
    audiences: [
      audience
    ]
  }
}

output clientId string = identity.properties.clientId
output principalId string = identity.properties.principalId
output githubSubject string = githubSubject
