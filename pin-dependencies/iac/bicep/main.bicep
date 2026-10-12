// Bicep: pin registry modules to an exact version tag, and every resource to an explicit API version.
// Azure Verified Modules live in the public registry (br/public:avm/...). Check the tags with:
//   curl -s https://mcr.microsoft.com/v2/bicep/avm/res/storage/storage-account/tags/list
module storage 'br/public:avm/res/storage/storage-account:0.33.1' = {
  name: 'storage'
  params: {
    name: 'st${uniqueString(resourceGroup().id)}'
    skuName: 'Standard_ZRS'
  }
}

// Your own modules in a private registry: same rule, an exact tag (and keep tags immutable in the registry).
// module network 'br:myregistry.azurecr.io/bicep/network:1.4.2' = { ... }
