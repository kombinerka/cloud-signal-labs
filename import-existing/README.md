# Bring a portal-built resource under code: Terraform or Bicep

Companion code for the Cloud Signal Short **"Built in the Azure Portal? Import It Into Terraform, Don't Rebuild It"**.

Someone created a storage account by hand. You want it managed as code without deleting and recreating it.
Both tools can do it; the steps are the same idea: **generate a draft, clean it up, check until nothing would
change, then adopt.**

| Step | Terraform ([`terraform/`](terraform/)) | Bicep ([`bicep/`](bicep/)) |
|---|---|---|
| 1. Draft | `import` block + `terraform plan -generate-config-out=generated.tf` | `az group export --resource-ids <id> --export-format bicep` ([`export.sh`](bicep/export.sh)) |
| 2. Clean up | variables instead of hard-coded values, drop defaults ([`storage.tf.example`](terraform/storage.tf.example)) | parameters, drop read-only properties ([`storage.bicep`](bicep/storage.bicep)) |
| 3. Check | `terraform plan` until *1 to import, 0 to add, 0 to change, 0 to destroy* | `az deployment group what-if` until *NoChange* ([`adopt.sh`](bicep/adopt.sh)) |
| 4. Adopt | `terraform apply`: the resource is in state, untouched | deploy as a deployment stack: Azure tracks it, optional deny settings ([`adopt.sh --deploy`](bicep/adopt.sh)) |
| Hundreds of resources | `aztfexport resource-group --hcl-only --generate-import-block` | `az group export -g <rg> --export-format bicep`, one resource group at a time |

In both cases: if the check wants to change or replace something, the code doesn't match reality yet. Fix the code,
not the resource.

## Terraform, step by step

```bash
cd terraform
# import.tf: to = the Terraform address, id = the Azure resource ID
az storage account show -g rg-reports -n streportsprod01 --query id -o tsv
terraform init
terraform plan -generate-config-out=generated.tf   # writes a draft, changes nothing
# clean generated.tf up into storage.tf (see storage.tf.example), delete generated.tf
terraform plan                                     # until: 1 to import, 0 to add, 0 to change, 0 to destroy
terraform apply
```

The `import` block can stay as a record or be removed; it does nothing once the resource is in state.
Needs Terraform 1.5 or later.

## Bicep, step by step

```bash
cd bicep
RG=rg-reports NAME=streportsprod01 ./export.sh     # exported.bicep, a draft
# clean exported.bicep up into storage.bicep
RG=rg-reports ./adopt.sh                           # what-if until nothing changes
RG=rg-reports ./adopt.sh --deploy                  # create the deployment stack
```

Bicep has no state file and no import step. Deploying a template that describes an existing resource updates it in
place, so the only thing that matters is that what-if shows no changes first. Deploying it as a
[deployment stack](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks) makes Azure
track the resource as part of the stack and can block changes outside it.

## Which one?

Pick the tool your team already runs, so the adopted resource lives with the rest of your code. The
[azure-takeover](../azure-takeover/) folder compares both for a whole estate.

## Sources

- Terraform: Import block: https://developer.hashicorp.com/terraform/language/import
- Terraform: Generating configuration: https://developer.hashicorp.com/terraform/language/import/generating-configuration
- Azure Export for Terraform: https://learn.microsoft.com/en-us/azure/developer/terraform/azure-export-for-terraform/export-terraform-overview
- Azure CLI: az group export: https://learn.microsoft.com/cli/azure/group
- Bicep: deployment stacks: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks
