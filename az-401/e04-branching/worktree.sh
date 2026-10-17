#!/usr/bin/env bash
# AZ-401 Episode 4 - Git worktree: a second working folder for the same repository.
# Pinecone example: fix a bug on a new branch without touching the work in progress in this folder.
# Commands as shown in the GitHub Blog article "What are git worktrees, and why should I use them?".
set -euo pipefail

# Create a sibling folder ../hotfix-workspace with a NEW branch hotfix-bug, based on main.
git worktree add ../hotfix-workspace -b hotfix-bug main

# ...work, commit and open a pull request from ../hotfix-workspace...
# Note: Git won't check out the same branch in two worktrees.

# After the pull request is merged, remove the extra folder (run from the main project folder).
git worktree remove ../hotfix-workspace
