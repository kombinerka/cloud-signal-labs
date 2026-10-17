#!/usr/bin/env bash
# AZ-401 Episode 5 - remove a leaked file from ALL history (GitHub Docs: "Removing sensitive data from a repository").
# STEP 0 (not Git): revoke or rotate the leaked secret first.
# Needs git-filter-repo 2.47+ (for --sensitive-data-removal). Run in a FRESH clone.
# Rewrites history: commit hashes change, collaborators must re-clone, forks keep their copies.
# GitHub: temporarily allow force pushes; PR refs (refs/pull/*) need GitHub Support.
# Azure Repos: you need the "Force push" permission.
set -euo pipefail
git-filter-repo --sensitive-data-removal --invert-paths --path config/db.env
git push --force --mirror origin
