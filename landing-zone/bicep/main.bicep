// A minimal landing zone to learn from: management groups, subscription placement, two inherited policies and a hub
// network. For a real platform use the Azure Landing Zones accelerator (see ../README.md).
//   az deployment tenant create -l westeurope -f main.bicep -p main.bicepparam
// Needs: rights to deploy at tenant scope (Management Group Contributor at the tenant root group), Owner on the
// subscriptions you place, and Network Contributor in the connectivity subscription.
targetScope = 'tenant'

param prefix string = 'orchard'
param displayName string = 'Orchard'
param allowedLocations array = ['westeurope', 'northeurope']
param connectivitySubscriptionId string
param managementSubscriptionId string
@description('Workload subscriptions that connect to the corporate network (e.g. Orchard production)')
param corpSubscriptionIds array = []
param hubAddressSpace string = '10.0.0.0/22'

// --- management groups: <prefix> > platform (management, connectivity, identity, security)
//                                  > landing zones (corp, online) > sandbox, decommissioned
resource root 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: prefix
  properties: {
    displayName: displayName
  }
}

resource platform 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${prefix}-platform'
  properties: {
    displayName: 'Platform'
    details: { parent: { id: root.id } }
  }
}

resource platformChildren 'Microsoft.Management/managementGroups@2023-04-01' = [
  for name in ['Management', 'Connectivity', 'Identity', 'Security']: {
    name: '${prefix}-${toLower(name)}'
    properties: {
      displayName: name
      details: { parent: { id: platform.id } }
    }
  }
]

resource landingZones 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${prefix}-landingzones'
  properties: {
    displayName: 'Landing zones'
    details: { parent: { id: root.id } }
  }
}

resource corp 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${prefix}-corp'
  properties: {
    displayName: 'Corp'
    details: { parent: { id: landingZones.id } }
  }
}

resource online 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${prefix}-online'
  properties: {
    displayName: 'Online'
    details: { parent: { id: landingZones.id } }
  }
}

resource other 'Microsoft.Management/managementGroups@2023-04-01' = [
  for name in ['Sandbox', 'Decommissioned']: {
    name: '${prefix}-${toLower(name)}'
    properties: {
      displayName: name
      details: { parent: { id: root.id } }
    }
  }
]

// --- subscription placement: moving a subscription changes which policies apply. It moves no packets.
resource connectivityPlacement 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  parent: platformChildren[1] // Connectivity
  name: connectivitySubscriptionId
}

resource managementPlacement 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  parent: platformChildren[0] // Management
  name: managementSubscriptionId
}

resource corpPlacement 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = [
  for subId in corpSubscriptionIds: {
    parent: corp
    name: subId
  }
]

// --- policies, inherited by everything below the scope they're assigned to
module allowedLocationsPolicy 'policy-assignment.bicep' = {
  name: 'policy-allowed-locations'
  scope: managementGroup(root.name)
  params: {
    name: 'allowed-locations'
    displayName: 'Allowed locations'
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    parameters: { listOfAllowedLocations: { value: allowedLocations } }
  }
}

// Corp workloads reach the internet through the hub, so they don't get their own public IPs.
module corpNoPublicIp 'policy-assignment.bicep' = {
  name: 'policy-corp-no-public-ip'
  scope: managementGroup(corp.name)
  params: {
    name: 'corp-no-public-ip'
    displayName: 'Corp: no public IP addresses'
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749'
    parameters: { listOfResourceTypesNotAllowed: { value: ['Microsoft.Network/publicIPAddresses'] } }
  }
}

// --- hub network in the Connectivity subscription (spokes peer to it, see ../../hub-spoke-peering)
module hub 'hub.bicep' = {
  name: 'hub-network'
  scope: subscription(connectivitySubscriptionId)
  params: {
    prefix: prefix
    location: allowedLocations[0]
    addressSpace: hubAddressSpace
  }
  dependsOn: [connectivityPlacement]
}
