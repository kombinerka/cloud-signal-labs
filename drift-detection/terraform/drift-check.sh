#!/usr/bin/env bash
# Terraform drift check. Exit 0 = Azure matches the code, 2 = differences, 1 = error.
# Signs in from the environment (ARM_USE_OIDC/ARM_* in CI, or ARM_USE_CLI after az login).
set -uo pipefail
cd "$(dirname "$0")" || exit 1
terraform init -input=false >/dev/null || exit 1
terraform plan -detailed-exitcode -lock=false -input=false -no-color
