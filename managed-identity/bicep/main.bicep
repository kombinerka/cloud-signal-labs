// The chain from the video: a VM with a system-assigned managed identity reads a secret from Key Vault.
// Identity on, token for the right audience, network path, and a role on the right scope: all four are needed.
//   az deployment group create -g rg-mi -f main.bicep -p name=<unique-suffix> sshPublicKey="$(cat ~/.ssh/id_ed25519.pub)" deployerObjectId=$(az ad signed-in-user show --query id -o tsv)
param name string
param location string = resourceGroup().location
param sshPublicKey string
param adminUsername string = 'azureuser'
@description('Your object ID, so you can create the demo secret')
param deployerObjectId string

var secretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
var secretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' // Key Vault Secrets Officer

// --- the target: Key Vault in RBAC mode (permissions are Azure role assignments, not access policies)
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-mi-${name}'
  location: location
  properties: {
    tenantId: tenant().tenantId
    sku: { family: 'A', name: 'standard' }
    enableRbacAuthorization: true
  }
}

resource deployerOfficer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vault.id, deployerObjectId, secretsOfficerRoleId)
  scope: vault
  properties: {
    principalId: deployerObjectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsOfficerRoleId)
  }
}

// ARM creates secrets through the control plane, so this works even before the data-plane role propagates.
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vault
  name: 'db-password'
  properties: { value: 'change-me' }
}

// --- the caller: a VM with a system-assigned identity (created and deleted with the VM)
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-mi'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.20.0.0/24'] }
    subnets: [{ name: 'snet-vm', properties: { addressPrefix: '10.20.0.0/26' } }]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'nic-vm-mi'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: { id: vnet.properties.subnets[0].id }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm-mi-app'
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    hardwareProfile: { vmSize: 'Standard_B2s' }
    osProfile: {
      computerName: 'vm-mi-app'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: { publicKeys: [{ path: '/home/${adminUsername}/.ssh/authorized_keys', keyData: sshPublicKey }] }
      }
    }
    storageProfile: {
      imageReference: { publisher: 'Canonical', offer: 'ubuntu-24_04-lts', sku: 'server', version: 'latest' }
      osDisk: { createOption: 'FromImage', managedDisk: { storageAccountType: 'Standard_LRS' } }
    }
    networkProfile: { networkInterfaces: [{ id: nic.id }] }
  }
}

// --- authorization: without this, the token is valid, the identity is real, and access is still denied.
resource vmSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vault.id, vm.id, secretsUserRoleId)
  scope: vault
  properties: {
    principalId: vm.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsUserRoleId)
  }
}

output vaultUrl string = vault.properties.vaultUri
output vmPrincipalId string = vm.identity.principalId
