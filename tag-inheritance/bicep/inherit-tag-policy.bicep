// Alternative: write the resource group's tag onto the resources themselves with Azure Policy
// ("Inherit a tag from the resource group if missing", built-in, modify effect).
// Unlike the Cost Management setting this CHANGES resources (adds tags).
//   az deployment sub create -l westeurope -f inherit-tag-policy.bicep -p tagName=costCenter
targetScope = 'subscription'

param tagName string = 'costCenter'
param location string = deployment().location

var definitionId = '/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070'
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c' // the role the policy definition asks for

resource assignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'inherit-${toLower(tagName)}-from-rg'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Inherit ${tagName} from the resource group if missing'
    policyDefinitionId: definitionId
    parameters: {
      tagName: {
        value: tagName
      }
    }
  }
}

resource policyIdentityRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, assignment.id, contributorRoleId)
  properties: {
    principalId: assignment.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
  }
}

// New and updated resources get the tag automatically. Existing ones need a remediation task.
resource remediation 'Microsoft.PolicyInsights/remediations@2024-10-01' = {
  name: 'inherit-${toLower(tagName)}-existing'
  properties: {
    policyAssignmentId: assignment.id
  }
  dependsOn: [
    policyIdentityRole
  ]
}
