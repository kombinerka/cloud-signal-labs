// Pinecone shop: give the deploy identity Contributor on ONE resource group,
// not on the subscription (the automatic service connection option assigns
// Contributor on the selected subscription).
// Deploy at resource group scope:
//   az deployment group create -g rg-pinecone-shop -f role-assignment.bicep \
//     -p principalId=<object ID of the service principal or managed identity>
targetScope = 'resourceGroup'

@description('Object (principal) ID of the deploy identity: the service connection\'s service principal or user-assigned managed identity')
param principalId string

@description('Built-in Contributor role. Contributor cannot assign roles in Azure RBAC.')
param roleDefinitionGuid string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)

resource deployContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // deterministic name: redeploying does not create a second assignment
  name: guid(resourceGroup().id, principalId, contributorRoleId)
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: principalId
    principalType: 'ServicePrincipal'
    description: 'Pinecone deploy identity: Contributor on rg-pinecone-shop only'
  }
}

output scope string = resourceGroup().id
