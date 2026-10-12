#!/usr/bin/env bash
# Promote the SAME artifact to an environment. Only the configuration around it changes (config/<env>.env).
# Usage: ./deploy.sh <dev|staging|production> dist/shop-<version>.tar.gz
set -euo pipefail
env="${1:?environment}"; artifact="${2:?artifact}"
cd "$(dirname "$0")"
(cd "$(dirname "$artifact")" && sha256sum -c "$(basename "$artifact").sha256")   # exactly what the build produced
set -a
# shellcheck disable=SC1090
. "config/${env}.env"
set +a
echo "Deploying $(basename "$artifact") to $env (VAT_RATE=$VAT_RATE)"
# Replace with your real deployment, for example:
#   az webapp deploy -g "rg-shop-$env" -n "app-shop-$env" --src-path "$artifact" --type zip
#   kubectl set image deployment/shop shop=myregistry.azurecr.io/shop@sha256:<digest>
