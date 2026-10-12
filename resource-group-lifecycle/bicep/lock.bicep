resource noDelete 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'no-delete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Production data. A delete of this group stops here.'
  }
}
