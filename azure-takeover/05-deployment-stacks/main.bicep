// A small workload deployed as a deployment stack. Every parameter has a default, so PSRule can expand it.
param location string = resourceGroup().location
param prefix string = 'app'
param env string = 'dev'

var suffix = uniqueString(resourceGroup().id)

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-${prefix}-${env}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.20.0.0/16']
    }
    // Subnets inline: the template describes the whole network. Pick one style (inline or separate
    // child resources) and keep it, so no tool "forgets" a subnet the other one created.
    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.20.1.0/24'
        }
      }
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take('st${prefix}${env}${suffix}', 24)
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

output storageAccountName string = storage.name
