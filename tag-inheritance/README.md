# Tag the resource group, see it on the bill

Companion code for the Cloud Signal Short **"Tagged the Resource Group? Your Azure Costs Are Still Untagged"**.

Tags on a subscription or resource group don't flow down to the resources inside. Every cost line belongs to a
resource, so cost analysis grouped by that tag mostly shows *untagged*. Two fixes, and they do different things:

| | Cost Management tag inheritance | Azure Policy "Inherit a tag from the resource group" |
|---|---|---|
| Changes | the **cost records** only | the **resources** (adds the tag) |
| Touches resources | no | yes, so it needs an identity with Contributor |
| Shows up in | cost analysis, exports, budgets | everywhere tags are read (Resource Graph, scripts, other tools) |
| Existing data | current month updated within ~8-24 h | existing resources need a remediation task |
| Conflict | resource's own tag wins by default; can prefer the inherited one | "if missing" only adds; the "add or replace" variant overwrites |
| How | [`enable-cost-tag-inheritance.sh`](enable-cost-tag-inheritance.sh), or the portal: Cost Management → settings → Tag inheritance | Terraform: [`terraform/inherit-tag-policy.tf`](terraform/inherit-tag-policy.tf) · Bicep: [`bicep/inherit-tag-policy.bicep`](bicep/inherit-tag-policy.bicep) |

If the goal is "the bill adds up", the Cost Management setting is enough and changes nothing. Use the policy when the
tag has to be on the resources themselves, for example because automation or access reviews read it.

```bash
# Cost Management setting (resource tags win on conflict)
SUBSCRIPTION_ID=<subscription-id> ./enable-cost-tag-inheritance.sh

# Policy, Terraform
cd terraform && terraform init && terraform apply -var tag_name=costCenter

# Policy, Bicep
az deployment sub create -l westeurope -f bicep/inherit-tag-policy.bicep -p tagName=costCenter
```

Both policy examples use the built-in definition *Inherit a tag from the resource group if missing*
(`ea3f2387-9b95-492a-a190-fcdc54f7b070`) and create a remediation task for resources that already exist.

## Sources

- Microsoft: Group and allocate costs using tag inheritance: https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/enable-tag-inheritance
- Cost Management REST API, Settings: https://learn.microsoft.com/en-us/rest/api/cost-management/settings/create-or-update-by-scope
- Azure Policy built-in definitions for tags: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-policies
