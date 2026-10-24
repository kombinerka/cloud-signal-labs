# Validation (2026-10-16)

Files: `azure-pipelines.yml`, `role-assignment.bicep`, `role-assignment.tf`, `versions.tf`, `verify.sh`.

```
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines.yml   # OK
bicep build role-assignment.bicep --stdout >/dev/null    # Bicep CLI 0.48.1: OK, no warnings
bicep lint role-assignment.bicep                         # no findings
terraform fmt -check                                     # OK
# in a temp copy of the .tf files:
terraform init -backend=false && terraform validate      # Terraform 1.9.8, hashicorp/azurerm 4.81.0: "The configuration is valid."
bash -n verify.sh                                        # OK
```

Validated, not deployed: nothing was run against a live Azure DevOps organization or Azure tenant.
The YAML parse checks syntax only; the Azure Pipelines schema (deployment job, `environment`, `runOnce`)
follows the Microsoft Learn "Deployment jobs" page.

The protections reviewed in the video are NOT in these files, on purpose: pipeline permissions, Approvals and
checks (Branch control, Approvals, Business hours, Exclusive lock), branch policies, the pipeline settings and
group membership are set in Azure DevOps, where people who edit the YAML can't change them.

Names (pinecone-shop, pinecone-prod, rg-pinecone-shop, app-pinecone-shop) are fictional. Contributor role
definition ID `b24988ac-6180-42a0-ab88-20f7382dd24c` is the built-in Contributor role.
