// Pinecone shop infrastructure (AZ-401 episode 11) - Bicep version.
// App Service plan + web app + staging slot + App Configuration store.
// Deploy: az deployment group create -g <rg> --parameters main.bicepparam
@description('Short environment name, e.g. dev or prod.')
param environmentName string

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('App Service plan SKU. Deployment slots need Standard or higher.')
param planSku string = 'S1'

var appName = 'pinecone-shop-${environmentName}'

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-${appName}'
  location: location
  kind: 'linux'
  sku: {
    name: planSku
  }
  properties: {
    reserved: true // required for Linux plans
  }
}

resource web 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      minTlsVersion: '1.2'
    }
  }
}

resource staging 'Microsoft.Web/sites/slots@2023-12-01' = {
  parent: web
  name: 'staging'
  location: location
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
  }
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: 'appcs-${appName}'
  location: location
  sku: {
    name: 'standard'
  }
}

output webAppName string = web.name
output appConfigEndpoint string = appConfig.properties.endpoint
