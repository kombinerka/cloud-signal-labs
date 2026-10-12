#!/usr/bin/env bash
# Week one, read-only: export what exists, who holds Owner, where the money goes, and the security posture.
# Needs: az login with Reader on the subscriptions (plus Cost Management Reader for costs). Changes nothing.
# Output: ./discovery/<date>/ with JSON/CSV you can diff week by week.
set -euo pipefail
out="discovery/$(date -u +%F)"
mkdir -p "$out"
az extension add --name resource-graph --only-show-errors >/dev/null 2>&1 || true

graph() { # graph <name> <query>  -> all pages into one JSON array
  local token="" page=0 tmp
  tmp=$(mktemp -d)
  while :; do
    az graph query -q "$2" --first 1000 ${token:+--skip-token "$token"} -o json > "$tmp/$page.json"
    token=$(jq -r '.skip_token // empty' "$tmp/$page.json")
    page=$((page + 1))
    [ -z "$token" ] && break
  done
  jq -s '[.[].data[]]' "$tmp"/*.json > "$out/$1.json"
  rm -rf "$tmp"
  echo "$1: $(jq length "$out/$1.json") rows"
}

graph all-resources 'resources | project id, name, type, location, resourceGroup, subscriptionId, tags'
graph resource-groups 'resourcecontainers | where type =~ "microsoft.resources/subscriptions/resourcegroups" | project id, name, subscriptionId, tags'
graph owners 'authorizationresources
  | where type =~ "microsoft.authorization/roleassignments"
  | extend roleId = tostring(split(properties.roleDefinitionId, "/")[-1])
  | where roleId in ("8e3af657-a8ff-443c-a75c-2fe8c4bcb635", "18d7d88d-d35e-4fb7-a5e3-5773c4a3d1b9")
  | project roleId, principalId = tostring(properties.principalId), principalType = tostring(properties.principalType), scope = tostring(properties.scope)'
graph secure-score 'securityresources | where type =~ "microsoft.security/securescores" | project subscriptionId, current = properties.score.current, max = properties.score.max'
graph advisor 'advisorresources | where type =~ "microsoft.advisor/recommendations" | project subscriptionId, category = tostring(properties.category), impact = tostring(properties.impact), problem = tostring(properties.shortDescription.problem), resource = tostring(properties.resourceMetadata.resourceId)'

# Cost per resource group, month to date, for every subscription you can see
for sub in $(az account list --query "[?state=='Enabled'].id" -o tsv); do
  az rest --method post \
    --url "https://management.azure.com/subscriptions/$sub/providers/Microsoft.CostManagement/query?api-version=2023-11-01" \
    --body '{"type":"ActualCost","timeframe":"MonthToDate","dataset":{"granularity":"None","aggregation":{"totalCost":{"name":"Cost","function":"Sum"}},"grouping":[{"type":"Dimension","name":"ResourceGroupName"}]}}' \
    -o json > "$out/cost-$sub.json" 2>/dev/null || echo "no cost access for $sub"
done

echo "Written to $out"
