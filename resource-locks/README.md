# Resource locks: why even the Owner can't delete it

▶ **[Watch the video](https://www.youtube.com/watch?v=4zQmKBkhLvw)**

Companion code for the Cloud Signal Short **"Why Azure Won't Let Even the Owner Delete This (Resource Locks)"**.

A lock sits on a subscription, a resource group or a resource, and everything below inherits it. It applies to
everyone, Owners included. To delete, someone with `Microsoft.Authorization/locks/delete` (Owner or User Access
Administrator) must remove the lock first. That extra step is the point: it stops the accidental click, not a
determined admin.

| Lock | Read | Change | Delete |
|---|---|---|---|
| `CanNotDelete` (Delete) | yes | yes | no |
| `ReadOnly` | yes* | no | no |

\* Read-only also blocks some reads that are POST calls, such as listing storage account keys, and can break things
like scaling or backups. Prefer Delete locks; use Read-only on single resources.

## Options

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) (`azurerm_management_lock`) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) (`Microsoft.Authorization/locks`) |
| Azure CLI | below |

```bash
az lock create --name no-delete --lock-type CanNotDelete --resource-group rg-data-prod
az lock list --resource-group rg-data-prod -o table
az lock delete --name no-delete --resource-group rg-data-prod   # the deliberate step before a delete
```

Locks and code: when Terraform or Bicep needs to delete a locked resource, the deployment fails. That's usually what
you want. If you deploy with Bicep deployment stacks, their deny settings (`denyDelete`, `denyWriteAndDelete`) do a
similar job for everything in the stack, see [azure-takeover](../azure-takeover/05-deployment-stacks/).

Policy decides what is allowed to exist. A lock protects what already does.

## Sources

- Microsoft: Lock your resources: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources
