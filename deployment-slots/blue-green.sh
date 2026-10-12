#!/usr/bin/env bash
# Blue-green with slots: production = blue, staging = green.
#   1. deploy the new version to staging   2. test it   3. swap all traffic at once
# Rollback = swap again (the old version is now in staging, still warm).
# Usage: RG=rg-myapp APP=myapp PACKAGE=app.zip ./blue-green.sh
set -euo pipefail
: "${RG:?}" "${APP:?}" "${PACKAGE:?}"

az webapp deploy -g "$RG" -n "$APP" --slot staging --src-path "$PACKAGE" --type zip
host=$(az webapp show -g "$RG" -n "$APP" --slot staging --query defaultHostName -o tsv)
echo "Testing https://$host/health"
curl -fsS --retry 10 --retry-delay 6 --retry-all-errors "https://$host/health" >/dev/null

az webapp deployment slot swap -g "$RG" -n "$APP" --slot staging --target-slot production
echo "Swapped. Roll back with: az webapp deployment slot swap -g $RG -n $APP --slot staging --target-slot production"
