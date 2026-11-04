# Validation (2026-10-30)

Files: `main.bicep`, `main.tf`, `versions.tf`, `github-deploy.yml`, `azure-pipelines.yml`, `check-subject.sh`.

```
bicep build main.bicep --stdout >/dev/null            # Bicep CLI 0.48.1: OK, no warnings
terraform fmt -check                                  # OK
# in a temp copy of the folder:
terraform init -backend=false && terraform validate   # Terraform 1.9.8, hashicorp/azurerm 4.81.0: "The configuration is valid."
python3 -c "import yaml; yaml.safe_load(open(f))"     # PyYAML 6.0.3: github-deploy.yml OK, azure-pipelines.yml OK
bash -n check-subject.sh                              # OK (shellcheck is not installed in the build box)
```

Not deployed, not run against a live subscription, GitHub or Azure DevOps. Names (pinecone-gear/shop,
id-pinecone-shop-gh, rg-pinecone-shop, pinecone-prod, github-shop-production, ado-pinecone-prod) are fictional.

Notes
- The GitHub subject is built from parameters in the documented format `repo:<Organization/Repository>:environment:<Name>`.
  `githubEnvironment` / `github_environment` defaults to `Production` because Pinecone fixes the credential side to match
  the workflow (`environment: name: Production`). If you fix the workflow side instead, change both to `production`.
- The credential name is lowercased (`github-shop-production`); only the subject has to match case-sensitively. Names
  are immutable after creation, so changing the environment parameter creates a new credential and deletes the old one.
- The Azure Pipelines credential is created only when both `pipelinesIssuer` and `pipelinesSubject` are set
  (`pipelines_issuer` / `pipelines_subject` in Terraform). Copy both from the service connection in Azure DevOps.
- The Pipelines credential waits for the GitHub one (`dependsOn` / `depends_on`): creating credentials on one identity
  one after the other is a cautious choice, not something verified for this video.
- PyYAML reads the workflow's `on:` key as the boolean `true` (YAML 1.1); GitHub reads it as `on`. This is normal for
  GitHub workflow files and is not an error.
- `check-subject.sh` uses `az identity federated-credential list --identity-name --resource-group`, documented in the
  Azure CLI reference. It compares the subject exactly and then with both sides lowercased (`${var,,}`, bash 4+).
  It covers user-assigned managed identities only (app registrations are not covered).
