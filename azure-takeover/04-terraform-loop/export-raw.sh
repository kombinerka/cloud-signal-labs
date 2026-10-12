#!/usr/bin/env bash
# Step 1 of the loop: export resource groups, one at a time, into raw/<rg>/ as a draft.
# --hcl-only writes code and import blocks but no state, so nothing is imported yet; the real import happens
# later, through import blocks in a reviewed pull request.
# Usage: ./export-raw.sh rg-app-dev rg-data-dev ...      (needs aztfexport, az login with Reader)
set -euo pipefail
[ $# -gt 0 ] || { echo "usage: $0 <resource-group>..."; exit 2; }
for rg in "$@"; do
  if [ -d "raw/$rg" ]; then echo "skip $rg (raw/$rg exists)"; continue; fi
  echo "== exporting $rg"
  aztfexport resource-group \
    --non-interactive --plain-ui \
    --hcl-only --generate-import-block \
    --include-role-assignment \
    --name-pattern '{type}_{name}' \
    --output-dir "raw/$rg" \
    "$rg"
done
