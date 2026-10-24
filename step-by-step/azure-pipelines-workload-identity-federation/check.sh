#!/usr/bin/env bash
# Verify the Azure side after setup. Read-only.
#   RG=rg-pinecone-shop ID=id-pinecone-shop-deploy ./check.sh
set -euo pipefail
RG="${RG:-rg-pinecone-shop}"
ID="${ID:-id-pinecone-shop-deploy}"

echo "== Identity"
az identity show -g "$RG" -n "$ID" --query "{clientId:clientId, principalId:principalId, tenantId:tenantId}" -o table

echo "== Federated credentials (issuer must start with https://login.microsoftonline.com/ for new connections)"
az identity federated-credential list -g "$RG" --identity-name "$ID" --query "[].{name:name, issuer:issuer, subject:subject, audiences:join(',', audiences)}" -o table

echo "== Role assignments (expect one, on the resource group)"
PRINCIPAL=$(az identity show -g "$RG" -n "$ID" --query principalId -o tsv)
az role assignment list --assignee "$PRINCIPAL" --all --query "[].{role:roleDefinitionName, scope:scope}" -o table
