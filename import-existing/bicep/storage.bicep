// What exported.bicep can look like after cleanup: parameters where values differ per environment,
// read-only and default properties removed. Same storage account as ../terraform/storage.tf.example.
param name string = 'streportsprod01'
param location string = resourceGroup().location

resource reports 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
  tags: {
    owner: 'reporting'
  }
}
