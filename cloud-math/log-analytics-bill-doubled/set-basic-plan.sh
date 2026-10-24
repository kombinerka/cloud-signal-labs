#!/usr/bin/env bash
# Move one table to the Basic plan (cheaper ingestion; queries billed per GB scanned; check feature support first).
#   RG=rg-pinecone-ops WS=log-pinecone-shop ./set-basic-plan.sh
set -euo pipefail
RG="${RG:-rg-pinecone-ops}"
WS="${WS:-log-pinecone-shop}"
TABLE="${TABLE:-ContainerLogV2}"
az monitor log-analytics workspace table show -g "$RG" --workspace-name "$WS" -n "$TABLE" --query "{table:name, plan:plan, retention:retentionInDays}" -o table
az monitor log-analytics workspace table update -g "$RG" --workspace-name "$WS" -n "$TABLE" --plan Basic
az monitor log-analytics workspace table show -g "$RG" --workspace-name "$WS" -n "$TABLE" --query "{table:name, plan:plan}" -o table
