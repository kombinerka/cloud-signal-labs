#!/usr/bin/env bash
# Application Gateway returns 502: check what the health probe sees before blaming capacity. Read-only.
# Usage: RG=rg-appgw GW=agw-shop ./diagnose.sh
set -euo pipefail
: "${RG:?}" "${GW:?}"
echo "== Backend health (what the probe gets back, per server):"
az network application-gateway show-backend-health -g "$RG" -n "$GW" \
  --query "backendAddressPools[].backendHttpSettingsCollection[].servers[].{address:address, health:health, log:healthProbeLog}" -o table
echo
echo "== Probes: host and path they send"
az network application-gateway probe list -g "$RG" --gateway-name "$GW" \
  --query "[].{name:name, host:host, pickHostFromSettings:pickHostNameFromBackendHttpSettings, path:path, match:match.statusCodes}" -o table
echo
echo "== Backend settings: host header sent to the backend"
az network application-gateway http-settings list -g "$RG" --gateway-name "$GW" \
  --query "[].{name:name, hostName:hostName, pickHostFromBackend:pickHostNameFromBackendAddress, probe:probe.id}" -o table
echo
echo "No host on the probe and no host on the settings means the probe sends the backend's IP as Host."
echo "A hostname-sensitive app (virtual hosts, App Service, many web servers) answers that with 404 -> unhealthy -> 502."
