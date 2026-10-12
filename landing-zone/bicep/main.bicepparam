using 'main.bicep'

param prefix = 'orchard'
param displayName = 'Orchard'
param allowedLocations = ['westeurope', 'northeurope']
param connectivitySubscriptionId = '00000000-0000-0000-0000-000000000001'
param managementSubscriptionId = '00000000-0000-0000-0000-000000000002'
param corpSubscriptionIds = ['00000000-0000-0000-0000-000000000003'] // Orchard production
