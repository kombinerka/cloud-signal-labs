// Delete locks on a list of production resource groups.
//   az deployment sub create -l westeurope -f locks.bicep -p resourceGroupNames='["rg-app-prod","rg-data-prod"]'
targetScope = 'subscription'

param resourceGroupNames array

module lock 'lock-rg.bicep' = [
  for rg in resourceGroupNames: {
    name: 'lock-${rg}'
    scope: resourceGroup(rg)
  }
]
