// Application Gateway v2 in front of a hostname-sensitive backend (e.g. an App Service app or a virtual-host web
// server). The fix from the video: the custom probe sends the hostname the app expects, and so do the requests.
//   az deployment group create -g rg-appgw -f main.bicep -p backendFqdn=myapp.azurewebsites.net
param location string = resourceGroup().location
param backendFqdn string
param healthPath string = '/health'

var gwName = 'agw-shop'
var gwId = resourceId('Microsoft.Network/applicationGateways', gwName)

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-appgw'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.30.0.0/24'] }
    subnets: [{ name: 'snet-appgw', properties: { addressPrefix: '10.30.0.0/26' } }] // its own subnet
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-appgw'
  location: location
  sku: { name: 'Standard' }
  zones: ['1', '2', '3']
  properties: { publicIPAllocationMethod: 'Static' }
}

resource gw 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: gwName
  location: location
  zones: ['1', '2', '3']
  properties: {
    sku: { name: 'Standard_v2', tier: 'Standard_v2', capacity: 1 }
    gatewayIPConfigurations: [{ name: 'gw-ip', properties: { subnet: { id: vnet.properties.subnets[0].id } } }]
    frontendIPConfigurations: [{ name: 'public', properties: { publicIPAddress: { id: pip.id } } }]
    frontendPorts: [{ name: 'http', properties: { port: 80 } }]
    httpListeners: [
      {
        name: 'http'
        properties: {
          frontendIPConfiguration: { id: '${gwId}/frontendIPConfigurations/public' }
          frontendPort: { id: '${gwId}/frontendPorts/http' }
          protocol: 'Http'
        }
      }
    ]
    backendAddressPools: [{ name: 'app', properties: { backendAddresses: [{ fqdn: backendFqdn }] } }]
    // Requests to the backend carry the backend's hostname as Host (not an IP).
    backendHttpSettingsCollection: [
      {
        name: 'app-https'
        properties: {
          protocol: 'Https'
          port: 443
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true // or: hostName: 'app.example.test'
          probe: { id: '${gwId}/probes/app-health' }
        }
      }
    ]
    // THE FIX: a custom probe that sends the hostname the app expects and checks a real health path.
    // Without it, the default probe sends the backend's IP as Host -> 404 -> unhealthy -> 502.
    probes: [
      {
        name: 'app-health'
        properties: {
          protocol: 'Https'
          path: healthPath
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true // or: host: 'app.example.test'
          match: { statusCodes: ['200-399'] }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'app'
        properties: {
          priority: 100
          ruleType: 'Basic'
          httpListener: { id: '${gwId}/httpListeners/http' }
          backendAddressPool: { id: '${gwId}/backendAddressPools/app' }
          backendHttpSettings: { id: '${gwId}/backendHttpSettingsCollection/app-https' }
        }
      }
    ]
  }
}
