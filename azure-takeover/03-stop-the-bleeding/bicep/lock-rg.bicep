// Used by locks.bicep: one Delete lock on the resource group it is deployed to.
resource noDelete 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'no-delete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Takeover: protect production until it is under code'
  }
}
