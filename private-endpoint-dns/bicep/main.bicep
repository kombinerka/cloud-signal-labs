// Storage account reachable only through a private endpoint, WITH the private DNS that makes the normal name
// resolve to the private IP inside the virtual network.
//   az deployment group create -g rg-pe-demo -f main.bicep -p name=<globally-unique-name>
param name string
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-pe-demo'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/24'] }
    subnets: [{ name: 'snet-private-endpoints', properties: { addressPrefix: '10.0.0.0/26' } }]
  }
}

resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: { name: 'Standard_ZRS' }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled' // only the private path is left
    minimumTlsVersion: 'TLS1_2'
  }
}

// 1. The private DNS zone for this service (Blob). Private DNS zones are global resources.
resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

// 2. Link it to the virtual network.
resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: zone
  name: 'link-vnet-pe-demo'
  location: 'global'
  properties: {
    virtualNetwork: { id: vnet.id }
    registrationEnabled: false
  }
}

// 3. The endpoint ...
resource pe 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pe-${name}-blob'
  location: location
  properties: {
    subnet: { id: vnet.properties.subnets[0].id }
    privateLinkServiceConnections: [
      { name: 'blob', properties: { privateLinkServiceId: st.id, groupIds: ['blob'] } }
    ]
  }
}

// ... with a DNS zone group: it registers (and later removes) its A record in the zone.
resource dnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: pe
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [{ name: 'blob', properties: { privateDnsZoneId: zone.id } }]
  }
}
