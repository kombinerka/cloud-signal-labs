#!/usr/bin/env bash
# Step 1 (Bicep): export the hand-built resource as a Bicep draft. Read-only.
# Usage: RG=rg-reports NAME=streportsprod01 ./export.sh   -> exported.bicep
set -euo pipefail
: "${RG:?set RG}" "${NAME:?set NAME (storage account name)}"
id=$(az storage account show -g "$RG" -n "$NAME" --query id -o tsv)
az group export --resource-group "$RG" --resource-ids "$id" \
  --export-format bicep --skip-all-params > exported.bicep
echo "Draft written to exported.bicep. Clean it up into storage.bicep, then run ./adopt.sh"
