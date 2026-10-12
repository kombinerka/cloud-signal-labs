#!/usr/bin/env bash
# List pipeline dependencies that are referenced by a movable label instead of a fixed commit/version/digest.
# Read-only. Usage: ./find-unpinned.sh [repo-dir]   (default: current directory)
set -euo pipefail
cd "${1:-.}"
sha='[0-9a-f]{40}'
found=0
report() { printf '%s\n' "$1"; found=1; }

# GitHub Actions: uses: owner/repo@<not a 40-char SHA>   (local ./actions and docker:// handled separately)
while IFS= read -r line; do report "github-action  $line"; done < <(
  grep -rnE --include='*.yml' --include='*.yaml' '^\s*-?\s*uses:\s*[^./][^@ ]+@' .github 2>/dev/null |
    grep -vE "@$sha(\s|$)" || true)

# GitLab: include ref that isn't a SHA, and components on a moving version
while IFS= read -r line; do report "gitlab-include $line"; done < <(
  grep -rnE --include='.gitlab-ci.yml' --include='*.gitlab-ci.yml' '^\s*ref:\s*' . 2>/dev/null |
    grep -vE "ref:\s*['\"]?$sha" || true)
while IFS= read -r line; do report "gitlab-component $line"; done < <(
  grep -rnE --include='*.yml' --include='*.yaml' 'component:.*@(~latest|[0-9]+(\.[0-9]+)?)\s*$' . 2>/dev/null || true)

# Azure Pipelines: task pinned to a major version only (Task@2 instead of Task@2.y.z)
while IFS= read -r line; do report "ado-task       $line"; done < <(
  grep -rnE --include='*.yml' --include='*.yaml' '^\s*-?\s*task:\s*[A-Za-z0-9_.-]+@[0-9]+\s*$' . 2>/dev/null || true)

# Container images without a digest (image:, container:, docker://)
while IFS= read -r line; do report "image          $line"; done < <(
  grep -rnE --include='*.yml' --include='*.yaml' '^\s*-?\s*(image|container):\s*\S+|docker://' . 2>/dev/null |
    grep -vE '@sha256:[0-9a-f]{64}' | grep -vE '(image|container):\s*\$|:\s*(\{|\[)' || true)

[ "$found" = 0 ] && echo "Everything found is pinned." || exit 1
