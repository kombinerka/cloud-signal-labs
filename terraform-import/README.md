# Import a portal-built resource into Terraform

Companion code for the Cloud Signal Short **"Built in the Azure Portal? Import It Into Terraform, Don't Rebuild It"**.

Someone created a storage account by hand. You want it managed by Terraform without deleting and recreating it.

## Steps

1. Put the resource ID in an `import` block ([`import.tf`](import.tf)). `to` is the Terraform address it should get,
   `id` is the Azure resource ID:

   ```bash
   az storage account show -g rg-reports -n streportsprod01 --query id -o tsv
   ```

2. Let Terraform write a first draft of the configuration:

   ```bash
   terraform init
   terraform plan -generate-config-out=generated.tf
   ```

   Terraform reads the real resource and writes `generated.tf`. Nothing in Azure changes.

3. Treat `generated.tf` as a draft. Move the resource into a proper file (see [`storage.tf.example`](storage.tf.example)):
   variables instead of hard-coded names and locations, remove attributes that are just defaults, keep what is
   intentional. Then delete `generated.tf`.

4. Plan again until it says **No changes**:

   ```bash
   terraform plan
   # Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
   ```

   If the plan wants to change or replace something, your cleaned-up code doesn't match reality yet. Fix the code, not
   the resource.

5. Apply. The resource is now in state, untouched:

   ```bash
   terraform apply
   ```

   You can remove the `import` block afterwards, or keep it as a record. It does nothing once the resource is in state.

## Hundreds of resources?

[Azure Export for Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/azure-export-for-terraform/export-terraform-overview)
(`aztfexport`) does the same for a whole resource group, and can write import blocks instead of touching state:

```bash
aztfexport resource-group --non-interactive --hcl-only --generate-import-block \
  --output-dir raw/rg-reports rg-reports
```

The [azure-takeover](../azure-takeover/) folder has a loop for doing this one resource group at a time.

## Requirements

Terraform 1.5 or later (import blocks and `-generate-config-out`), the `azurerm` provider, and Reader on the resource
to plan (Contributor or a custom role to apply tag or setting changes later).

## Sources

- Terraform: Import block: https://developer.hashicorp.com/terraform/language/import
- Terraform: Generating configuration: https://developer.hashicorp.com/terraform/language/import/generating-configuration
