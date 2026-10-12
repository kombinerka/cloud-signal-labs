#!/usr/bin/env bash
# Run ON the VM: what the SDK does under the hood. Ask the local Instance Metadata Service for a token whose
# audience is Key Vault, then show the claims that matter (no signature check; for inspection only).
set -euo pipefail
resource="${1:-https://vault.azure.net}"
token=$(curl -s -H Metadata:true \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=${resource}" |
  python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
payload=$(cut -d. -f2 <<<"$token" | tr '_-' '/+')
while [ $(( ${#payload} % 4 )) -ne 0 ]; do payload="${payload}="; done
base64 -d <<<"$payload" | python3 -c 'import sys,json; c=json.load(sys.stdin); print({k: c.get(k) for k in ("aud","iss","oid","xms_mirid","exp")})'
