# Validation (2026-10-16)

Files: `azure-pipelines.yml`, `.github/workflows/deploy.yml`, `identity.bicep`, `identity.tf`, `versions.tf`.

```
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines.yml            # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/deploy.yml   # OK
bicep build identity.bicep --stdout >/dev/null        # Bicep CLI 0.48.1: OK, no warnings
terraform fmt -check                                  # OK
# in a temp copy of the folder:
terraform init -backend=false && terraform validate   # Terraform 1.9.8, hashicorp/azurerm 4.81.0: "The configuration is valid."
```

Not deployed or run against a live tenant. Names (pinecone-prod-wif, rg-pinecone-shop, id-pinecone-deploy,
pinecone-gear/shop) are fictional. The Azure DevOps issuer and subject are parameters on purpose: copy them from
the service connection screen (Microsoft Learn: "DevOps automatically creates the subject identifier").
No secrets in any file: azure/login reads client, tenant and subscription IDs from GitHub secrets.
`azurerm_federated_identity_credential` uses `user_assigned_identity_id` (in azurerm 4.81 `parent_id` and
`resource_group_name` are deprecated).
