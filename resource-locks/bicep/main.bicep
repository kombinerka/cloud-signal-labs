// Delete lock on the resource group this is deployed to. Everything inside inherits it.
//   az deployment group create -g rg-data-prod -f main.bicep
resource noDelete 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'no-delete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Production data. Remove the lock deliberately before deleting anything.'
  }
}

// On a single resource, use scope:
// resource archive 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
//   name: 'starchive001'
// }
// resource readOnly 'Microsoft.Authorization/locks@2020-05-01' = {
//   name: 'read-only'
//   scope: archive
//   properties: {
//     level: 'ReadOnly'
//   }
// }
