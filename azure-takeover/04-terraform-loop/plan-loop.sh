#!/usr/bin/env bash
# Steps 3-4 of the loop: plan the cleaned-up code for one resource group until nothing but imports is left.
# Usage: ./plan-loop.sh envs/dev/app      (a Terraform root with the cleaned code + import blocks)
# Exit 0 = only imports left (ready for a pull request), 1 = something else would change.
set -euo pipefail
dir="${1:?usage: $0 <terraform-dir>}"
terraform -chdir="$dir" plan -input=false -out=tfplan > /dev/null
terraform -chdir="$dir" show -json tfplan > "$dir/tfplan.json"
python3 "$(dirname "$0")/plan-summary.py" "$dir/tfplan.json"
