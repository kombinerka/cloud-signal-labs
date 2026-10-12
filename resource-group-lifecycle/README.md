# Delete one resource group, lose everything in it

Companion code for the Cloud Signal Short **"Delete One Azure Resource Group, Lose Everything In It"**.

A resource group is a container: deleting it deletes everything inside. Every resource lives in exactly one group
(you can move it, never share it). So **group by lifecycle**: what is created and deleted together belongs
together, and what has to survive gets its own group and a Delete lock.

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) |
| Check before deleting | [`before-delete.sh`](before-delete.sh): lists what goes with the group, locks, and anything tagged `prod` |

Both examples create a test group meant to be deleted as a whole and a separate production data group with a Delete
lock. More on locks: [resource-locks](../resource-locks/).

## Sources

- Microsoft: Manage resource groups: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
- Microsoft: Move resources to a new resource group: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription
- Microsoft: Lock your resources: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources
