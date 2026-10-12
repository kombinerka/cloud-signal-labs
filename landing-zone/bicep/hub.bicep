// Hub resource group and network in the Connectivity subscription.
targetScope = 'subscription'

param prefix string
param location string
param addressSpace string

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-hub'
  location: location
}

module vnet 'hub-vnet.bicep' = {
  name: 'hub-vnet'
  scope: rg
  params: {
    prefix: prefix
    location: location
    addressSpace: addressSpace
  }
}
