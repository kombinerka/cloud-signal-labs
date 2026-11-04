#!/usr/bin/env bash
# No-plugin alternative. certbot --manual-cleanup-hook: remove the DNS-01 value again.
set -euo pipefail
az network dns record-set txt remove-record -g "${DNS_RG:?}" -z "${DNS_ZONE:?}" \
    -n "${DNS_RECORD:?}" -v "$CERTBOT_VALIDATION" --keep-empty-record-set
