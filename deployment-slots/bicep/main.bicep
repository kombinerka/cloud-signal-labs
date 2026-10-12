// App Service with a staging slot. Slots need the Standard tier or higher.
//   az deployment group create -g rg-myapp -f main.bicep -p name=<globally-unique-name>
param name string
param location string = resourceGroup().location

resource plan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'asp-${name}'
  location: location
  kind: 'linux'
  sku: {
    name: 'S1'
  }
  properties: {
    reserved: true // Linux
  }
}

var siteConfig = {
  linuxFxVersion: 'NODE|22-lts'
  healthCheckPath: '/health'
}

resource app 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: siteConfig
  }
}

// Blue-green: deploy here, test, swap. Canary: route a percentage of production traffic here.
resource staging 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: app
  name: 'staging'
  location: location
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: siteConfig
  }
}

// Traffic routing (siteConfig.experiments.rampUpRules) changes during a release, so canary.sh sets it,
// not this template; otherwise every deployment would reset it.
