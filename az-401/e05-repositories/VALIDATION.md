# Validation (2026-10-16, git 2.43.0)

| File | Command | Result |
|---|---|---|
| pre-commit | `bash -n pre-commit` | OK |
| pre-commit | throwaway repo: copied to `.git/hooks/pre-commit`; committed `ok.txt` (`size=42`) | accepted |
| pre-commit | same repo: committed `config.env` containing `DB_PASSWORD=...` | blocked (exit 1, message printed) |
| pre-commit | same commit with `git commit --no-verify` | accepted (shows why a hook is not enforcement) |
| tag-release.sh | `bash -n`; `git tag -a -m "Spring sale release" v1.4.0` then `git cat-file -t v1.4.0` in the throwaway repo | OK, object type `tag` (annotated) |
| migrate-ado-to-github.sh | `bash -n` | OK (syntax only). Not run: needs Azure DevOps and GitHub orgs and tokens; `gh extension install github/gh-ado2gh` could not be fetched from this sandbox. Commands and flags are copied from GitHub Docs (see ../SOURCES.md). |
| remove-secret.sh | `bash -n` | OK (syntax only). Not run: git-filter-repo is not installed here. Command copied from GitHub Docs "Removing sensitive data from a repository". |

No secrets in these files: tokens come from the shell environment (`ADO_PAT`, `GH_PAT`).
