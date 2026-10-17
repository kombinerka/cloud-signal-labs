# Prompt used in the episode (adapted from the Microsoft Learn module "Use GitHub Copilot for cloud operations")

Create an Azure Pipelines YAML file for pinecone-shop with stages Validate, Deploy Staging and Deploy Production.
Trigger only on changes under infra/ on main. Use the variable group pinecone-infra.
All stages run on ubuntu-latest. Use the AzureCLI task for deployments.

Translate it into a GitHub Actions workflow with jobs validate, deploy-staging and deploy-production.
Map stages to jobs with needs, variable groups to environment secrets, and the service connection to OIDC via azure/login.
Preserve all logic. Do not add features that are not in the original pipeline.

Review before merging: service connection names exist; runtime values use $(var), not ${{ variables.var }};
approvals are configured on the environment, not in the YAML.
