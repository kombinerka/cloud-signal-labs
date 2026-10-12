#!/usr/bin/env bash
# Look before you delete a resource group: everything inside goes with it. Read-only.
# Usage: ./before-delete.sh rg-shop-test
set -euo pipefail
rg="${1:?resource group}"
echo "== Resources that would be deleted with $rg:"
az resource list -g "$rg" --query "[].{name:name, type:type, environment:tags.environment}" -o table
echo
echo "== Locks (a Delete lock anywhere inside blocks the whole delete):"
az lock list -g "$rg" --query "[].{name:name, level:level, scope:id}" -o table
prod=$(az resource list -g "$rg" --query "[?tags.environment=='prod'] | length(@)" -o tsv)
if [ "$prod" != "0" ]; then
  echo
  echo "WARNING: $prod resource(s) in $rg are tagged environment=prod. Move them to a long-lived group first:"
  echo "  az resource move --destination-group <rg> --ids <resource-id>"
fi
