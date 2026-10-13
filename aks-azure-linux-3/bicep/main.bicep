// Keep the template in line after migrating, or the next deployment puts the node pool back.
param clusterName string

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' existing = {
  name: clusterName
}

resource apps 'Microsoft.ContainerService/managedClusters/agentPools@2024-09-01' = {
  parent: aks
  name: 'apps'
  properties: {
    vmSize: 'Standard_D4s_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux3' // was 'AzureLinux' on Kubernetes < 1.32 (= Azure Linux 2.0)
    mode: 'User'
    enableAutoScaling: true
    count: 2
    minCount: 2
    maxCount: 10
  }
}
