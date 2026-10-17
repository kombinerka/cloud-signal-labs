# Validation (AZ-401 episode 8, run 2026-10-16)

Commands run from this `code/` folder:

```
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines.yml               # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/ci.yml          # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/after-ci.yml    # OK
python3 -c "import yaml; yaml.safe_load(open('.github/instructions/actions.instructions.md').read().split('---')[1])"  # front matter OK
```

What this proves: the files parse. Nothing was run against a live Azure DevOps organization or GitHub repository
(names are fictional). Keys follow the Azure Pipelines YAML schema pages (trigger, pr, schedules,
resources.pipelines.pipeline.trigger, pool name/demands/vmImage) and GitHub Docs (on: push/pull_request filters,
paths-ignore, schedule, workflow_dispatch inputs, workflow_run, runs-on labels, permissions), see ../SOURCES.md.
The `.github/instructions/` folder for path-specific Copilot instructions was not confirmed on a page read for this
episode (the docs page shows the file name actions.instructions.md and the applyTo front matter).
No secrets in any file.
