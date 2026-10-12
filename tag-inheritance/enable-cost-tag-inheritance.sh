#!/usr/bin/env bash
# Turn on Cost Management tag inheritance for a subscription (or any supported scope).
# Subscription and resource group tags are then copied onto the cost records of everything inside.
# No resource changes; the current month's usage is updated within about 8-24 hours.
# Needs Cost Management Contributor (or Contributor) on the scope.
# Usage: SUBSCRIPTION_ID=<id> ./enable-cost-tag-inheritance.sh            resource tags win on conflict
#        SUBSCRIPTION_ID=<id> PREFER_INHERITED=true ./enable-cost-tag-inheritance.sh   inherited tag wins
set -euo pipefail
sub="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv)}"
prefer="${PREFER_INHERITED:-false}"
api="${API_VERSION:-2026-06-01}"

az rest --method put \
  --url "https://management.azure.com/subscriptions/${sub}/providers/Microsoft.CostManagement/settings/taginheritance?api-version=${api}" \
  --body "{\"kind\": \"taginheritance\", \"properties\": {\"preferContainerTags\": ${prefer}}}"

# Check it:
az rest --method get \
  --url "https://management.azure.com/subscriptions/${sub}/providers/Microsoft.CostManagement/settings/taginheritance?api-version=${api}" \
  --query properties
