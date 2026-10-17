# Validation (2026-10-16)

| File | Command | Result |
|---|---|---|
| worktree.sh | `bash -n worktree.sh` | OK |
| worktree.sh | ran in a throwaway repo: `git init -b main`, empty commit, `bash worktree.sh`, then `git worktree list` | OK: worktree created on new branch `hotfix-bug`, then removed; branch `hotfix-bug` remains |

Git version used: 2.43.0. The commands match the GitHub Blog article
"What are git worktrees, and why should I use them?" (see ../SOURCES.md).
