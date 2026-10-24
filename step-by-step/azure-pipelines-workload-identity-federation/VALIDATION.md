# Validation (2026-10-22)

```
bicep build identity.bicep --stdout >/dev/null          # OK, no warnings
terraform fmt -check                                    # OK
terraform init -backend=false && terraform validate     # Terraform 1.9.8, hashicorp/azurerm 4.81.0: valid
python3 -c "import yaml; yaml.safe_load(open('azure-pipelines.yml'))"   # OK
bash -n check.sh                                        # OK
```

Not deployed or run against a live subscription or Azure DevOps organization. UI labels and step order are from
Microsoft Learn "Manually set an Azure Resource Manager workload identity service connection" (last updated
2026-08-18) and the troubleshooting page (issuer/subject formats, errors).
