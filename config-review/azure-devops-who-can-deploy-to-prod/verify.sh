#!/usr/bin/env bash
# Pinecone shop: list every Azure role assignment of the deploy identity.
# Expected: one line, Contributor, scope .../resourceGroups/rg-pinecone-shop.
# Usage: ./verify.sh <object ID of the service principal or managed identity>
set -euo pipefail
ID="${1:?object ID of the deploy identity}"
az role assignment list --all --assignee "$ID" \
  --query "[].{role:roleDefinitionName, scope:scope}" --output table
