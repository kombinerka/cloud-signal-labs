#!/usr/bin/env bash
# List AKS node pools still on Azure Linux 2.0 and (optionally) switch one to Azure Linux 3.
# Azure Linux 2.0 = osSku "AzureLinux" on Kubernetes < 1.32 (or osSku "CBLMariner"). Node images are removed on
# October 31, 2026; affected pools can't scale after that.
# Usage: ./find-and-migrate.sh                                  list (all clusters you can see)
#        RG=rg CLUSTER=aks POOL=np1 ./find-and-migrate.sh --migrate   switch one pool to AzureLinux3
set -euo pipefail
if [ "${1:-}" = "--migrate" ]; then
  : "${RG:?}" "${CLUSTER:?}" "${POOL:?}"
  az aks nodepool update -g "$RG" --cluster-name "$CLUSTER" -n "$POOL" --os-sku AzureLinux3
  exit
fi
az aks list --query "[].{rg:resourceGroup, name:name}" -o tsv | while read -r rg name; do
  az aks nodepool list -g "$rg" --cluster-name "$name" \
    --query "[].{pool:name, osSku:osSku, k8s:orchestratorVersion, image:nodeImageVersion}" -o tsv |
  while read -r pool sku k8s image; do
    minor=$(cut -d. -f2 <<<"$k8s")
    if [ "$sku" = "CBLMariner" ] || { [ "$sku" = "AzureLinux" ] && [ "$minor" -lt 32 ]; }; then
      echo "AZURE LINUX 2.0  $rg/$name/$pool  k8s $k8s  $image"
    fi
  done
done
echo "Pools listed above need Kubernetes 1.32+ or --os-sku AzureLinux3 (try one pool first)."
