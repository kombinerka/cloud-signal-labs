#!/usr/bin/env bash
# Bicep drift check with what-if. Exit 0 = Azure matches the template, 2 = differences, 1 = error.
# Needs: az login (Reader is enough for what-if), RG = the resource group the template is deployed to.
# What-if can report noise (properties Azure fills in, references to existing resources), so changes of type
# Ignore and NoChange are filtered out and only Create/Delete/Modify/Deploy count.
set -uo pipefail
: "${RG:?set RG to the resource group}"
cd "$(dirname "$0")" || exit 1
result=$(az deployment group what-if --resource-group "$RG" --template-file main.bicep \
  --result-format FullResourcePayloads --no-pretty-print -o json) || exit 1
changes=$(jq '[.changes[] | select(.changeType != "NoChange" and .changeType != "Ignore")]' <<<"$result")
count=$(jq length <<<"$changes")
if [ "$count" -gt 0 ]; then
  jq -r '.[] | "\(.changeType)  \(.resourceId)" , (.delta[]? | "    \(.path): \(.before|tostring) -> \(.after|tostring)")' <<<"$changes"
  exit 2
fi
echo "No differences."
