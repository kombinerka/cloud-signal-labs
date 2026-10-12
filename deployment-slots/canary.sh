#!/usr/bin/env bash
# Canary with slots: send a share of production traffic to staging, raise it step by step, then swap.
# Users routed to a slot stay there (cookie) for about an hour, so each step is a stable sample.
# Usage: RG=rg-myapp APP=myapp ./canary.sh            (new version already deployed to staging)
#        STEPS="5 25 50" WAIT=600 RG=... APP=... ./canary.sh
set -euo pipefail
: "${RG:?}" "${APP:?}"
steps="${STEPS:-5 25 50}"
wait_s="${WAIT:-600}"

for pct in $steps; do
  az webapp traffic-routing set -g "$RG" -n "$APP" --distribution "staging=$pct" -o none
  echo "$(date -u +%T) staging gets ${pct}% of traffic. Watching for ${wait_s}s: errors and latency in Application Insights."
  sleep "$wait_s"
  # Replace this with a real check (failed requests, p95 latency) that exits non-zero on trouble.
  read -r -p "Healthy at ${pct}%? [y/N] " ok </dev/tty
  if [ "$ok" != y ]; then
    az webapp traffic-routing clear -g "$RG" -n "$APP" -o none
    echo "Rolled back: all traffic to production. Only ${pct}% of users saw the new version."
    exit 1
  fi
done

az webapp deployment slot swap -g "$RG" -n "$APP" --slot staging --target-slot production
az webapp traffic-routing clear -g "$RG" -n "$APP" -o none
echo "New version is production, routing cleared."
