#!/usr/bin/env bash
# List VMs that are "Stopped" but not deallocated: shut down from inside the OS, compute still billed.
# Read-only. Pass --deallocate to deallocate them (asks once per VM).
set -euo pipefail
az extension add --name resource-graph --only-show-errors >/dev/null 2>&1 || true
query='resources
| where type =~ "microsoft.compute/virtualmachines"
| extend state = tostring(properties.extended.instanceView.powerState.code)
| where state =~ "PowerState/stopped"
| project id, name, resourceGroup, subscriptionId, size = tostring(properties.hardwareProfile.vmSize), state'
rows=$(az graph query -q "$query" --first 1000 -o json | jq -c '.data[]')
[ -z "$rows" ] && { echo "No stopped-but-allocated VMs."; exit 0; }
jq -r '"\(.subscriptionId)  \(.resourceGroup)/\(.name)  \(.size)  \(.state)"' <<<"$rows"
if [ "${1:-}" = "--deallocate" ]; then
  while IFS= read -r vm; do
    id=$(jq -r .id <<<"$vm")
    read -r -p "Deallocate $(jq -r .name <<<"$vm")? [y/N] " ok </dev/tty
    [ "$ok" = y ] && az vm deallocate --ids "$id" --no-wait && echo "  deallocating"
  done <<<"$rows"
fi
