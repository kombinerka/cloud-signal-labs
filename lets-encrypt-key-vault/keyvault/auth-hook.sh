#!/usr/bin/env bash
# No-plugin alternative. certbot --manual-auth-hook: publish the DNS-01 value in Azure DNS.
# certbot sets CERTBOT_VALIDATION (the validation string) and CERTBOT_DOMAIN.
# CNAME delegation: _acme-challenge.pinecone-gear.example is a CNAME to
#   pinecone-gear.acme-challenges.example  -> DNS_ZONE=acme-challenges.example, DNS_RECORD=pinecone-gear
# so this identity needs DNS rights only on the challenge zone, never on the real zone.
set -euo pipefail
az network dns record-set txt add-record -g "${DNS_RG:?}" -z "${DNS_ZONE:?}" \
    -n "${DNS_RECORD:?}" -v "$CERTBOT_VALIDATION"
# Let's Encrypt docs: wait for propagation; the 60 s default is a guess.
sleep "${DNS_WAIT_SECONDS:-60}"
