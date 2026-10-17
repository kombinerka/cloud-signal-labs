# Validation (2026-10-16)

```
# Bicep (Bicep CLI 0.48.1)
bicep build infra/main.bicep --stdout >/dev/null              # OK, no warnings
bicep build-params infra/main.bicepparam --stdout >/dev/null  # OK
bicep lint infra/main.bicep                                   # no findings

# Terraform (Terraform 1.9.8, provider hashicorp/azurerm 4.81.0), in a temp copy of terraform/
terraform fmt -check                                          # OK
terraform init -backend=false && terraform validate           # Success! The configuration is valid.

# YAML parses (PyYAML 6.0.3)
for f in azure-pipelines.yml azure-pipelines-ci.yml .github/workflows/*.yml; do
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$f"; done             # all OK
# GitHub workflows lint
actionlint .github/workflows/*.yml                             # actionlint 1.7.12, 0 findings
```

Notes
- Azure Pipelines YAML was checked for parsing only (no Azure DevOps org used). Task inputs follow the Learn
  task reference (AzureCLI@2, Cache@2, PublishTestResults@2); `parallel` slicing variables
  System.JobPositionInPhase / System.TotalJobsInPhase from the "parallel testing for any test runner" article.
- The Bicep deploy steps follow Learn: Azure Pipelines quickstart (AzureCLI@2 + az deployment group create with a
  .bicepparam file) and "Deploy Bicep files by using GitHub Actions" (azure/login@v2 + azure/arm-deploy@v1).
- terraform.yml: hashicorp/setup-terraform@v4 (inputs checked in the action's action.yml). The ARM_USE_OIDC /
  ARM_CLIENT_ID / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID variables are azurerm provider settings (Terraform provider
  docs, not Microsoft Learn); the backend may need extra auth settings in your setup.
- azure-pipelines.yml's Terraform job assumes the Terraform CLI is on the agent.
- Nothing was deployed. All names (storage account, resource groups, apps) are fictional.
