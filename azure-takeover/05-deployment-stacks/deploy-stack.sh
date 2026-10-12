#!/usr/bin/env bash
# Deploy main.bicep as a deployment stack: Azure tracks the resources as one unit (no state file), and the deny
# settings block changes and deletes outside the stack, for everyone, Owners included, except the excluded
# principals (up to 5, e.g. a break-glass group). Removing a resource from the template detaches it (detachAll);
# use deleteResources or deleteAll to delete it instead.
# Usage: RG=rg-app-dev BREAK_GLASS_GROUP_ID=<object-id> ./deploy-stack.sh
set -euo pipefail
: "${RG:?set RG}"
: "${BREAK_GLASS_GROUP_ID:?set BREAK_GLASS_GROUP_ID (Entra group object ID allowed to bypass the deny settings)}"

az stack group create \
  --name "stack-${RG}" \
  --resource-group "$RG" \
  --template-file "$(dirname "$0")/main.bicep" \
  --action-on-unmanage detachAll \
  --deny-settings-mode denyWriteAndDelete \
  --deny-settings-apply-to-child-scopes \
  --deny-settings-excluded-principals "$BREAK_GLASS_GROUP_ID" \
  --yes
