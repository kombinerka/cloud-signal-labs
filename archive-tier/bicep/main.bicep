// Storage for backups with a lifecycle policy: hot -> cool after 30 days -> archive after 90 -> delete after 400.
// Archive is cheapest, but offline: reading needs a rehydration that can take up to 15 hours (see ../rehydrate.sh).
//   az deployment group create -g rg-backup -f main.bicep -p name=<globally-unique-name>
param name string
param location string = resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: { name: 'Standard_LRS' } // archive is supported on LRS, GRS and RA-GRS, not on ZRS/GZRS
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    accessTier: 'Hot'
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource backups 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blob
  name: 'backups'
}

resource lifecycle 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  parent: storage
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'backups-to-archive'
          enabled: true
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: ['blockBlob']
              prefixMatch: ['backups/']
            }
            actions: {
              baseBlob: {
                tierToCool: { daysAfterModificationGreaterThan: 30 }
                tierToArchive: { daysAfterModificationGreaterThan: 90 }
                // Archive has a 180-day minimum: deleting at day 400 means 310 days in archive, no early-deletion fee.
                delete: { daysAfterModificationGreaterThan: 400 }
              }
            }
          }
        }
      ]
    }
  }
}
