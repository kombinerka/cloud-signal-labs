// Group by lifecycle: what is created and deleted together lives together.
// The test environment is safe to delete as a whole; the production data has its own group and a Delete lock.
//   az deployment sub create -l westeurope -f main.bicep
targetScope = 'subscription'

param location string = 'westeurope'

// Deleted together after every test cycle.
resource test 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-shop-test'
  location: location
  tags: { lifecycle: 'ephemeral', environment: 'test' }
}

// Lives for years, independent of any test cycle.
resource dataProd 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-shop-data-prod'
  location: location
  tags: { lifecycle: 'long-lived', environment: 'prod' }
}

module lock 'lock.bicep' = {
  name: 'lock-data-prod'
  scope: dataProd
}
