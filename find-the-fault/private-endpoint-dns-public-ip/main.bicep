// Find the Fault #1: a private SQL endpoint that resolves to its public IP (Cloud Signal).
// Pinecone names are fictional. Validated with `bicep build`, not deployed.
//
// What this declares (the DNS side of a private endpoint for Azure SQL Database):
//   1. the private DNS zone privatelink.database.windows.net
//   2. two virtual network links (resolution only, no auto-registration):
//      - the shop VNet, where the app VM and the private endpoint live
//      - the hub VNet, where the custom DNS server (or the Private Resolver) lives.
//        Azure DNS only answers from a private zone for queries that come from a linked VNet,
//        so the network of the server that forwards to 168.63.129.16 needs its own link.
//   3. the private endpoint with a DNS zone group, so Azure keeps the A record in the zone
//   4. optional: an Azure DNS Private Resolver with an inbound endpoint in the hub
//      (deployPrivateResolver = true), the managed alternative to a forwarding DNS VM.
//
// The conditional forwarder on a Windows DNS server is not an Azure resource: see forwarder.ps1.

targetScope = 'resourceGroup'

@description('Region for the private endpoint and the resolver. Private DNS zones and their links are global.')
param location string = resourceGroup().location

@description('Resource ID of the existing logical SQL server (pinecone-sql).')
param sqlServerId string

@description('Resource ID of the shop VNet (app VM and private endpoint), e.g. vnet-pinecone-shop.')
param shopVnetId string

@description('Resource ID of the hub VNet that holds the custom DNS server or the Private Resolver, e.g. vnet-pinecone-hub.')
param hubVnetId string

@description('Resource ID of the subnet for the private endpoint (in the shop VNet).')
param endpointSubnetId string

@description('true = also deploy an Azure DNS Private Resolver with an inbound endpoint in the hub VNet.')
param deployPrivateResolver bool = false

@description('Resource ID of a dedicated subnet in the hub VNet delegated to Microsoft.Network/dnsResolvers (only used when deployPrivateResolver is true).')
param resolverInboundSubnetId string = ''

// Recommended zone name for Azure SQL Database in Azure public cloud (other clouds use another suffix).
#disable-next-line no-hardcoded-env-urls
var zoneName = 'privatelink.database.windows.net'

// 1. The private DNS zone (recommended name for Azure SQL Database, subresource sqlServer)
resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: zoneName
  location: 'global'
}

// 2a. Link to the shop VNet (clients that use Azure-provided DNS there can resolve the zone)
resource linkShop 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: zone
  name: 'link-vnet-pinecone-shop'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: shopVnetId
    }
  }
}

// 2b. Link to the hub VNet: the custom DNS server (or resolver) asks Azure DNS from here
resource linkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: zone
  name: 'link-vnet-pinecone-hub'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
}

// 3. The private endpoint for the SQL server ...
resource pe 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pe-pinecone-sql'
  location: location
  properties: {
    subnet: {
      id: endpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pinecone-sql'
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

// ... and its DNS zone group: Azure manages the A record (pinecone-sql -> private IP) in the zone
resource peDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: pe
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: zone.id
        }
      }
    ]
  }
}

// 4. Optional: Azure DNS Private Resolver in the hub. Point the DNS server's conditional forwarder
//    (or an on-premises DNS server's) at the inbound endpoint IP instead of 168.63.129.16.
resource resolver 'Microsoft.Network/dnsResolvers@2022-07-01' = if (deployPrivateResolver) {
  name: 'dnspr-pinecone-hub'
  location: location
  properties: {
    virtualNetwork: {
      id: hubVnetId
    }
  }
}

resource inbound 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = if (deployPrivateResolver) {
  parent: resolver
  name: 'inbound'
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: resolverInboundSubnetId
        }
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
}

output privateDnsZoneId string = zone.id
output linkedVnets array = [
  linkShop.properties.virtualNetwork.id
  linkHub.properties.virtualNetwork.id
]
output resolverInboundIp string = deployPrivateResolver ? inbound!.properties.ipConfigurations[0].privateIpAddress! : ''
