#!/usr/bin/env bash
# Run an AI agent (or any command it wants to run) in a throwaway container that sees ONLY this project:
#   - the current folder mounted at /work, nothing else from your machine (no ~/.ssh, ~/.azure, ~/.config)
#   - no credentials passed in (no env vars, no Git/cloud tokens)
#   - no network by default (NETWORK=bridge to allow it, ideally through an egress proxy with an allowlist)
#   - read-only root filesystem, no Linux capabilities, no privilege escalation, non-root user
# Usage: ./run-sandboxed.sh <image> <command...>
#   ./run-sandboxed.sh node:22-bookworm npx --yes some-agent-cli
#   NETWORK=bridge ./run-sandboxed.sh python:3.13-slim python tool.py
set -euo pipefail
image="${1:?image}"; shift
exec docker run --rm -it \
  --network "${NETWORK:-none}" \
  --read-only --tmpfs /tmp --tmpfs /home/agent \
  --cap-drop ALL --security-opt no-new-privileges \
  --user "$(id -u):$(id -g)" -e HOME=/home/agent \
  --pids-limit 512 --memory 4g \
  -v "$PWD":/work -w /work \
  "$image" "$@"
