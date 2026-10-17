# Validation (AZ-401 episode 7, run 2026-10-16)

Commands run from this `code/` folder:

```
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azure-pipelines.yml                         # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" loadtest/checkout.yaml                      # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" azurepipelines-coverage.yml                 # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/test.yml                  # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/copilot-setup-steps.yml   # OK
python3 -c "import json; json.load(open('.vscode/mcp.json'))"                                               # OK
```

What this proves: the files parse. Nothing was run against a live Azure DevOps organization, Azure Load Testing
resource or GitHub repository (all names are fictional). Task inputs and keys follow the Microsoft Learn and GitHub Docs
pages in ../SOURCES.md (DotNetCoreCLI@2 test, PublishTestResults@2, PublishCodeCoverageResults@2, AzureLoadTest@1,
the load test config YAML, azurepipelines-coverage.yml, actions/upload-code-coverage@v1, copilot-setup-steps,
remote Azure DevOps MCP server headers). The action versions actions/checkout@v6 and actions/upload-artifact@v4 are the
ones shown in GitHub Docs; actions/setup-python@v6 was not shown on a page we read, so check the latest major version
before use. No secrets: the load test uses an Azure Resource Manager service connection; the MCP config uses
Microsoft Entra sign-in of the remote server.
