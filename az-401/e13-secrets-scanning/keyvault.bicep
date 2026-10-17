// Pinecone shop: a Key Vault that uses Azure RBAC, and read-only access to
// secrets for the deploy identity from episode 12.
targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vaultName string = 'kv-pinecone-shop'

@description('principalId of id-pinecone-deploy (user-assigned managed identity)')
param deployPrincipalId string

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true   // Azure RBAC instead of access policies
    enablePurgeProtection: true
  }
}

// Key Vault Secrets User: read secret contents, nothing else.
var secretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource secretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vault.id, deployPrincipalId, secretsUserRoleId)
  scope: vault
  properties: {
    roleDefinitionId: secretsUserRoleId
    principalId: deployPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output vaultUri string = vault.properties.vaultUri
