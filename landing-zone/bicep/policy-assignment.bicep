// One policy assignment at the management group this module is deployed to.
targetScope = 'managementGroup'

param name string
param displayName string
param definitionId string
param parameters object = {}

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: name
  properties: {
    displayName: displayName
    policyDefinitionId: definitionId
    parameters: parameters
  }
}
