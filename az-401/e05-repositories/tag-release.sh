#!/usr/bin/env bash
# AZ-401 Episode 5 - create an annotated tag and push it with the commit.
# Azure Repos: needs the "Create tag" permission (Contributors have it by default).
set -euo pipefail
git tag -a -m "Spring sale release" v1.4.0
git push --follow-tags
