// The same NSG as ../terraform/main.tf: only 443 inbound. Rules inline, so the template owns the full rule list.
param location string = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-web-prod'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-https-in'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
