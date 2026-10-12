#!/usr/bin/env bash
# Put a Delete lock on every resource group whose name matches a pattern (default: *-prod*).
# Delete locks still allow reads and changes; they stop deletion, for everyone, Owners included.
# Dry run by default; pass --apply to create the locks. Needs Owner or User Access Administrator
# (Microsoft.Authorization/locks/write) on the resource groups.
set -euo pipefail
pattern="${PATTERN:-prod}"
apply=false
[ "${1:-}" = "--apply" ] && apply=true

for sub in $(az account list --query "[?state=='Enabled'].id" -o tsv); do
  while IFS= read -r rg; do
    [ -z "$rg" ] && continue
    if az lock list --subscription "$sub" -g "$rg" --query "[?level=='CanNotDelete'] | length(@)" -o tsv | grep -qv '^0$'; then
      echo "already locked  $sub/$rg"
    elif $apply; then
      az lock create --subscription "$sub" -g "$rg" --name "no-delete" --lock-type CanNotDelete \
        --notes "Takeover: protect production until it is under code" -o none
      echo "locked          $sub/$rg"
    else
      echo "would lock      $sub/$rg"
    fi
  done < <(az group list --subscription "$sub" --query "[?contains(name, '$pattern')].name" -o tsv)
done
$apply || echo "Dry run. Re-run with --apply to create the locks."
