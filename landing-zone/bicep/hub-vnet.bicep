param prefix string
param location string
param addressSpace string

// Subnet names Azure expects for firewall, VPN/ExpressRoute gateway and Bastion; /26 each from the hub range.
var subnetNames = ['AzureFirewallSubnet', 'GatewaySubnet', 'AzureBastionSubnet']

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-${prefix}-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressSpace]
    }
    subnets: [
      for (name, i) in subnetNames: {
        name: name
        properties: {
          addressPrefix: cidrSubnet(addressSpace, 26, i)
        }
      }
    ]
  }
}

output vnetId string = vnet.id
