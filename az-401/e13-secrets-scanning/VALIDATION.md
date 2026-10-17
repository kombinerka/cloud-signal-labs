# Validation (2026-10-16)

Files: `azure-pipelines.yml`, `azure-pipelines-ghas.yml`, `.github/workflows/deploy-keyvault.yml`, `keyvault.bicep`,
`keyvault.tf`, `versions.tf`.

```
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines.yml                    # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines-ghas.yml               # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/deploy-keyvault.yml  # OK
bicep build keyvault.bicep --stdout >/dev/null        # Bicep CLI 0.48.1: OK, no warnings
terraform fmt -check                                  # OK
# in a temp copy of the folder:
terraform init -backend=false && terraform validate   # Terraform 1.9.8, hashicorp/azurerm 4.81.0: "The configuration is valid."
```

Not run against a live organization or tenant. Task names and inputs come from the Azure Pipelines task reference
(AzureKeyVault@2, DownloadSecureFile@1, AdvancedSecurity-Codeql-Init@1, AdvancedSecurity-Dependency-Scanning@1,
AdvancedSecurity-Codeql-Analyze@1). The Learn GitHub Actions sample uses azure/login@v1 and azure/CLI@v1; this file
uses @v2 of both, matching the current "Authenticate to Azure from GitHub Actions by OpenID Connect" page.
Key Vault Secrets User role ID 4633458b-17de-408a-b874-0445c86b69e6 (Azure built-in roles, Security).
In azurerm 4.81 the vault uses `rbac_authorization_enabled` (validate shows no deprecation warning).
No secret values in any file. Names (kv-pinecone-shop, pinecone-shop-kv, pinecone-signing.pfx, storage-key) are fictional.
