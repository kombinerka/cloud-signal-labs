// After the upgrade, make the template match reality: kind StorageV2 and the access tier you chose.
param location string = resourceGroup().location

resource legacy 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stlegacy001'
  location: location
  kind: 'StorageV2' // was 'Storage' (GPv1)
  sku: {
    name: 'Standard_GRS' // keep what you had
  }
  properties: {
    accessTier: 'Hot' // or 'Cool': decide, don't inherit a default by accident
    minimumTlsVersion: 'TLS1_2'
  }
}
