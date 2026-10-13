#!/usr/bin/env bash
# Find general-purpose v1 storage accounts (kind "Storage") in every subscription you can see, and optionally
# upgrade them to GPv2 in place (no downtime, data and endpoints unchanged, NOT reversible).
# Usage: ./find-and-upgrade.sh                    list only
#        TIER=Hot ./find-and-upgrade.sh --upgrade  upgrade each one after asking (TIER: Hot or Cool)
set -euo pipefail
az extension add --name resource-graph --only-show-errors >/dev/null 2>&1 || true
rows=$(az graph query --first 1000 -o json -q "
resources
| where type =~ 'microsoft.storage/storageaccounts' and kind =~ 'Storage'
| project id, name, resourceGroup, subscriptionId, location, sku = tostring(sku.name)" | jq -c '.data[]')
[ -z "$rows" ] && { echo "No GPv1 storage accounts found."; exit 0; }
jq -r '"\(.subscriptionId)  \(.resourceGroup)/\(.name)  \(.sku)  \(.location)"' <<<"$rows"
if [ "${1:-}" = "--upgrade" ]; then
  tier="${TIER:?set TIER=Hot or TIER=Cool: the default access tier decides storage and transaction prices}"
  while IFS= read -r a; do
    read -r -p "Upgrade $(jq -r .name <<<"$a") to GPv2 ($tier)? This is permanent. [y/N] " ok </dev/tty
    [ "$ok" = y ] && az storage account update --ids "$(jq -r .id <<<"$a")" --set kind=StorageV2 --access-tier "$tier" -o none && echo "  upgraded"
  done <<<"$rows"
fi
