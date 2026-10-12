#!/usr/bin/env bash
# Verify a downloaded artifact on your machine before you run or ship it. Needs the GitHub CLI (gh auth login).
# Usage: ./verify-local.sh app.tar.gz my-org/my-app [workflow-file]
set -euo pipefail
file="${1:?artifact}"; repo="${2:?owner/repo}"; wf="${3:-.github/workflows/build-attest-verify.yml}"
gh attestation verify "$file" --repo "$repo" --signer-workflow "$repo/$wf" --source-ref refs/heads/main
# Change one byte of the file, or build it elsewhere, and this fails: no attestation matches the digest/identity.
