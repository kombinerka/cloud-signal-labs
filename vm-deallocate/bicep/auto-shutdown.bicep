// Auto-shutdown for a dev/test VM in this resource group. The VM ends up "Stopped (deallocated)".
//   az deployment group create -g rg-dev -f auto-shutdown.bicep -p vmName=vm-test-01
param vmName string
param location string = resourceGroup().location
param time string = '1900'
param timeZoneId string = 'W. Europe Standard Time'

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vmName
}

resource shutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}' // this exact name is what the portal's auto-shutdown uses
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: time
    }
    timeZoneId: timeZoneId
    targetResourceId: vm.id
    notificationSettings: {
      status: 'Disabled'
    }
  }
}
