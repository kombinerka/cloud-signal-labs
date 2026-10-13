#!/usr/bin/env bash
# Run INSIDE the virtual network (a VM, a container, Cloud Shell in the VNet). Read-only.
# Usage: ./check-dns.sh mystore.blob.core.windows.net
set -euo pipefail
host="${1:?hostname}"
out=$(nslookup "$host" || true)
echo "$out"
if grep -q "privatelink" <<<"$out" && grep -Eq "Address: (10|172\.(1[6-9]|2[0-9]|3[01])|192\.168)\." <<<"$out"; then
  echo "OK: resolves through privatelink to a private IP."
else
  echo "NOT PRIVATE: check the private DNS zone, its link to this VNet, and the endpoint's DNS zone group."
  echo "With custom DNS servers (or on-premises), forward the zone to Azure DNS (168.63.129.16) or a DNS Private Resolver."
fi
