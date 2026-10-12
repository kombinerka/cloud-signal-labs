// Hub and spoke: every spoke peers with the hub; spoke-to-spoke traffic goes through a firewall/NVA in the hub,
// steered there by a route table (peering is not transitive, so it never happens on its own).
//   az deployment group create -g rg-hub-spoke -f main.bicep
param location string = resourceGroup().location
param spokes array = [
  { name: 'a', addressSpace: '10.1.0.0/24' }
  { name: 'c', addressSpace: '10.2.0.0/24' }
]
@description('Private IP of the Azure Firewall or NVA in the hub that forwards spoke-to-spoke traffic')
param firewallPrivateIp string = '10.0.0.4'

resource hub 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-hub'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/24'] }
    subnets: [
      { name: 'AzureFirewallSubnet', properties: { addressPrefix: '10.0.0.0/26' } }
    ]
  }
}

// User-defined routes: traffic for every other spoke goes to the firewall in the hub.
resource routeTables 'Microsoft.Network/routeTables@2024-05-01' = [
  for s in spokes: {
    name: 'rt-spoke-${s.name}'
    location: location
    properties: {
      routes: [
        for other in filter(spokes, o => o.name != s.name): {
          name: 'to-spoke-${other.name}'
          properties: {
            addressPrefix: other.addressSpace
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: firewallPrivateIp
          }
        }
      ]
    }
  }
]

resource spokeVnets 'Microsoft.Network/virtualNetworks@2024-05-01' = [
  for (s, i) in spokes: {
    name: 'vnet-spoke-${s.name}'
    location: location
    properties: {
      addressSpace: { addressPrefixes: [s.addressSpace] }
      subnets: [
        {
          name: 'snet-workload'
          properties: {
            addressPrefix: s.addressSpace
            routeTable: { id: routeTables[i].id }
          }
        }
      ]
    }
  }
]

// A peering is one direction; each link needs both halves.
resource hubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = [
  for (s, i) in spokes: {
    parent: hub
    name: 'hub-to-${s.name}'
    properties: {
      remoteVirtualNetwork: { id: spokeVnets[i].id }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true // traffic the firewall forwards from another spoke
    }
  }
]

resource spokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = [
  for (s, i) in spokes: {
    name: 'vnet-spoke-${s.name}/${s.name}-to-hub'
    properties: {
      remoteVirtualNetwork: { id: hub.id }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
    }
    dependsOn: [spokeVnets]
  }
]

// The firewall itself (Azure Firewall or an NVA with IP forwarding) is not included; it costs money while it runs.
// Its private IP must match firewallPrivateIp, and it needs rules that allow the spoke-to-spoke traffic.
// Direct option for two or three networks: two peerings between the spokes themselves, no hub hop.
