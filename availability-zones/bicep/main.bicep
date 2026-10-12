// Three web VMs spread across availability zones 1, 2 and 3, behind a zone-redundant Standard load balancer.
// One zone fails: the health probe stops sending traffic there, the other two keep serving.
//   az deployment group create -g rg-shop-zones -f main.bicep -p sshPublicKey="$(cat ~/.ssh/id_ed25519.pub)"
param location string = resourceGroup().location
param sshPublicKey string
param adminUsername string = 'azureuser'
param zones array = ['1', '2', '3']

var cloudInit = '''#!/bin/sh
apt-get update && apt-get install -y nginx
echo "zone: $(curl -s -H Metadata:true 'http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01&format=text')" > /var/www/html/index.html
'''

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-web'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-http-in'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-shop'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.10.0.0/24'] }
    subnets: [
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.10.0.0/25'
          networkSecurityGroup: { id: nsg.id }
        }
      }
    ]
  }
}

// Standard public IP across zones: it keeps working when one zone is down.
resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-shop'
  location: location
  sku: { name: 'Standard' }
  zones: zones
  properties: { publicIPAllocationMethod: 'Static' }
}

resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: 'lb-shop'
  location: location
  sku: { name: 'Standard' }
  properties: {
    frontendIPConfigurations: [
      { name: 'public', properties: { publicIPAddress: { id: pip.id } } }
    ]
    backendAddressPools: [
      { name: 'web' }
    ]
    probes: [
      { name: 'http', properties: { protocol: 'Http', port: 80, requestPath: '/' } }
    ]
    loadBalancingRules: [
      {
        name: 'http'
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          frontendIPConfiguration: { id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'lb-shop', 'public') }
          backendAddressPool: { id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-shop', 'web') }
          probe: { id: resourceId('Microsoft.Network/loadBalancers/probes', 'lb-shop', 'http') }
        }
      }
    ]
  }
}

// Flexible scale set: 3 instances, spread over the zones.
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: 'vmss-web'
  location: location
  zones: zones
  sku: { name: 'Standard_B2s', capacity: 3 }
  properties: {
    orchestrationMode: 'Flexible'
    platformFaultDomainCount: 1
    zoneBalance: true
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'web'
        adminUsername: adminUsername
        customData: base64(cloudInit)
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              { path: '/home/${adminUsername}/.ssh/authorized_keys', keyData: sshPublicKey }
            ]
          }
        }
      }
      storageProfile: {
        imageReference: { publisher: 'Canonical', offer: 'ubuntu-24_04-lts', sku: 'server', version: 'latest' }
        osDisk: { createOption: 'FromImage', caching: 'ReadWrite', managedDisk: { storageAccountType: 'Premium_LRS' } }
      }
      networkProfile: {
        networkApiVersion: '2022-11-01'
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig'
                  properties: {
                    subnet: { id: vnet.properties.subnets[0].id }
                    loadBalancerBackendAddressPools: [{ id: lb.properties.backendAddressPools[0].id }]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

output url string = 'http://${pip.properties.ipAddress}'
