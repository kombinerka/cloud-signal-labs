#!/usr/bin/env bash
# AZ-401 Episode 5 - migrate Azure DevOps Cloud repos to GitHub Enterprise Cloud with GitHub Enterprise Importer.
# Fictional orgs: pinecone-ado (Azure DevOps) -> pinecone-gear (GitHub). Tokens come from your shell, never from this file.
set -euo pipefail

gh extension install github/gh-ado2gh

: "${ADO_PAT:?set ADO_PAT (Azure DevOps personal access token) first}"
: "${GH_PAT:?set GH_PAT (GitHub personal access token) first}"

# Writes a PowerShell script with one migration per repository. Review it before running.
# Optional: --all (rewire pipelines, create teams, configure Azure Boards integration),
#           --download-migration-logs
gh ado2gh generate-script --ado-org pinecone-ado --github-org pinecone-gear --output migrate.ps1

# 1. Trial run against a sandbox organization (e.g. pinecone-gear-sandbox).
# 2. Halt work in the source repositories (no delta migrations).
# 3. Run the reviewed script:  pwsh ./migrate.ps1
# Git LFS objects are not migrated: push them afterwards.
