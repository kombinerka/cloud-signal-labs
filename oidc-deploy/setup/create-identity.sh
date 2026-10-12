#!/usr/bin/env bash
# Create a deployment identity that GitHub Actions can use without a secret:
#   1. a user-assigned managed identity
#   2. a federated credential that trusts exactly one subject (repo + environment)
#   3. one role, on one resource group
# Requires: az login with rights to create identities and role assignments on the target resource group.
set -euo pipefail

GITHUB_REPO="${GITHUB_REPO:-my-org/my-app}"       # owner/repo
ENVIRONMENT="${ENVIRONMENT:-production}"            # GitHub environment the deploy job uses
IDENTITY_RG="${IDENTITY_RG:-rg-identities}"         # where the identity lives
TARGET_RG="${TARGET_RG:-rg-app-prod}"               # what it may deploy to
LOCATION="${LOCATION:-westeurope}"
IDENTITY_NAME="${IDENTITY_NAME:-id-deploy-${ENVIRONMENT}}"
ROLE="${ROLE:-Contributor}"                         # narrower is better, e.g. Website Contributor

az group create -n "$IDENTITY_RG" -l "$LOCATION" -o none
az identity create -g "$IDENTITY_RG" -n "$IDENTITY_NAME" -l "$LOCATION" -o none

# One credential = one subject. Wildcards are not supported; an identity holds at most 20 credentials.
az identity federated-credential create \
  --resource-group "$IDENTITY_RG" \
  --identity-name "$IDENTITY_NAME" \
  --name "github-${ENVIRONMENT}" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:${GITHUB_REPO}:environment:${ENVIRONMENT}" \
  --audiences "api://AzureADTokenExchange" \
  -o none

principal_id=$(az identity show -g "$IDENTITY_RG" -n "$IDENTITY_NAME" --query principalId -o tsv)
scope=$(az group show -n "$TARGET_RG" --query id -o tsv)
az role assignment create \
  --assignee-object-id "$principal_id" \
  --assignee-principal-type ServicePrincipal \
  --role "$ROLE" \
  --scope "$scope" \
  -o none

echo "Set these as GitHub variables (they are IDs, not secrets):"
echo "  AZURE_CLIENT_ID=$(az identity show -g "$IDENTITY_RG" -n "$IDENTITY_NAME" --query clientId -o tsv)"
echo "  AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)"
echo "  AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)"
