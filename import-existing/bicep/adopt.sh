#!/usr/bin/env bash
# Steps 2-3 (Bicep): check with what-if until nothing would change, then adopt the resource into a deployment
# stack. Bicep has no state file and no import step: deploying a template that describes an existing resource
# updates it in place (incremental), and the stack starts tracking it. Nothing is recreated.
# Usage: RG=rg-reports ./adopt.sh            (what-if only)
#        RG=rg-reports ./adopt.sh --deploy   (what-if, then create/update the stack)
set -euo pipefail
: "${RG:?set RG}"
cd "$(dirname "$0")"

az deployment group what-if -g "$RG" --template-file storage.bicep --result-format FullResourcePayloads
echo
echo "Expect 'Nochange' (or only 'Ignore'). If anything is 'Modify', the template doesn't match the resource yet:"
echo "fix the template, not the resource, and run again."

if [ "${1:-}" = "--deploy" ]; then
  # detachAll: if you later remove the resource from the template, the stack lets go of it instead of deleting it.
  # denyDelete: nobody can delete it outside the stack (use denyWriteAndDelete once all changes go through code).
  az stack group create --name "stack-reports" --resource-group "$RG" \
    --template-file storage.bicep \
    --action-on-unmanage detachAll \
    --deny-settings-mode denyDelete \
    --yes
fi
