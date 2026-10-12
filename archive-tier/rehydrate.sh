#!/usr/bin/env bash
# Get an archived blob back online. Two ways:
#   in place:  change its tier (the blob stays where it is)
#   copy:      copy it to a new blob in an online tier (the archived original stays, keeps its 180-day clock)
# Priority: Standard (up to 15 hours) or High (often under 1 hour for blobs under 10 GB, costs more).
# Usage: ACCOUNT=stbackup CONTAINER=backups BLOB=backups/db-2026-06-01.bak PRIORITY=High ./rehydrate.sh [--copy]
# Auth: --auth-mode login uses your Entra ID sign-in (needs Storage Blob Data Contributor).
set -euo pipefail
: "${ACCOUNT:?}" "${CONTAINER:?}" "${BLOB:?}"
priority="${PRIORITY:-Standard}"
tier="${TIER:-Hot}"

if [ "${1:-}" = "--copy" ]; then
  target="${BLOB%.*}-restored.${BLOB##*.}"
  az storage blob copy start --auth-mode login --account-name "$ACCOUNT" \
    --source-container "$CONTAINER" --source-blob "$BLOB" \
    --destination-container "$CONTAINER" --destination-blob "$target" \
    --tier "$tier" --rehydrate-priority "$priority"
  echo "Copy started to $target. It is readable once its rehydration finishes."
  BLOB="$target"
else
  az storage blob set-tier --auth-mode login --account-name "$ACCOUNT" \
    --container-name "$CONTAINER" --name "$BLOB" --tier "$tier" --rehydrate-priority "$priority"
  echo "Rehydration to $tier started with $priority priority."
fi

echo "Check progress (status shows rehydrate-pending-to-... until it is done, then the tier is online):"
echo "  az storage blob show --auth-mode login --account-name $ACCOUNT -c $CONTAINER -n '$BLOB' --query 'properties.{tier:blobTier, status:rehydrationStatus}'"
