#!/usr/bin/env bash
# Walk the checkpoints from the video for one VM and one Key Vault. Read-only.
# Usage: RG=rg-mi VM=vm-mi-app VAULT=kv-mi-<name> ./check.sh
set -euo pipefail
: "${RG:?}" "${VM:?}" "${VAULT:?}"

echo "1. Identity enabled on the VM?"
pid=$(az vm show -g "$RG" -n "$VM" --query identity.principalId -o tsv)
az vm show -g "$RG" -n "$VM" --query "identity.{type:type, systemAssigned:principalId, userAssigned:userAssignedIdentities}" -o json
[ -z "$pid" ] && echo "   No system-assigned identity. (User-assigned? The app must then ask for that client ID.)"

vault_id=$(az keyvault show -n "$VAULT" --query id -o tsv)
echo "2. Network: can the VM reach the vault?"
az keyvault show -n "$VAULT" --query "{publicNetworkAccess:properties.publicNetworkAccess, defaultAction:properties.networkAcls.defaultAction, privateEndpoints:length(properties.privateEndpointConnections || \`[]\`)}" -o json
echo "   If defaultAction is Deny: allow the VM's subnet or use a private endpoint (and private DNS)."

echo "3. Authorization model:"
az keyvault show -n "$VAULT" --query "{rbac:properties.enableRbacAuthorization}" -o json
echo "   rbac=true -> Azure role assignments count, access policies are ignored (and the other way round)."

echo "4. Role assignments for the VM's identity that reach the vault (vault, resource group, subscription):"
[ -n "$pid" ] && az role assignment list --assignee "$pid" --all \
  --query "[?starts_with('$vault_id', scope)].{role:roleDefinitionName, scope:scope}" -o table
echo "   Need a data-plane role such as 'Key Vault Secrets User'. 'Reader' or 'Contributor' do not read secrets."
echo "5. Just assigned? Role assignments can take a few minutes to apply; tokens issued before can be cached."
