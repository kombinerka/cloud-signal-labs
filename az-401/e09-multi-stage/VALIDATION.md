# Validation (2026-10-16)

```
# YAML parses (PyYAML 6.0.3)
for f in azure-pipelines.yml templates/deploy-steps.yml .github/workflows/ci.yml \
         .github/workflows/deploy.yml .github/actions/node-setup/action.yml; do
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$f"; done        # all OK
# agentic workflow front matter parses
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]).read().split('---')[1])" .github/workflows/ci-failure-report.md   # OK
# GitHub workflows lint
actionlint .github/workflows/ci.yml .github/workflows/deploy.yml                     # actionlint 1.7.12, 0 findings
# agentic workflow compiles
gh aw compile ci-failure-report       # gh-aw built from github/gh-aw main (version "dev"): 1 succeeded, 0 warnings
```

Notes
- The compiled `ci-failure-report.lock.yml` is NOT committed here: it was produced by a development build of
  gh-aw. Run `gh extension install github/gh-aw` and `gh aw compile` yourself, then commit both files.
- Early compiles warned (fixed): the default GitHub toolset needs `pull-requests: read`, and a `workflow_run`
  trigger should have a `branches` filter.
- `copilot-requests: write` bills Copilot use to the organization (org admin must allow Copilot CLI billing).
  On a personal repository, use a `COPILOT_GITHUB_TOKEN` secret instead (see GitHub Docs).
- Azure Pipelines YAML was checked for parsing only (no Azure DevOps org was used). Task inputs follow the
  Learn task reference (AzureWebApp@1, UseNode@1).
- Nothing was run against a live Azure DevOps organization, GitHub repository or Azure subscription.
