# Validation (2026-10-16)

```
python3 -c "import json,sys; json.load(open(sys.argv[1]))" .vscode/mcp.json                    # OK
python3 -c "import json,sys; json.load(open(sys.argv[1]))" copilot-cloud-agent-mcp.json         # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/workflows/copilot-setup-steps.yml   # OK
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" .github/release.yml             # OK
# YAML front matter of the agent, skill and instructions files parsed with yaml.safe_load       # OK
```

Shapes checked against the docs (not run against a live org or repository):
- `.vscode/mcp.json`: remote Azure DevOps MCP Server (`https://mcp.dev.azure.com/{organization}`, `X-MCP-Toolsets`, `X-MCP-Readonly`; toolsets `wit`, `wiki`) and GitHub remote MCP server (`https://api.githubcopilot.com/mcp/`, toolsets `repos`, `issues`, `pull_requests`, `X-MCP-Readonly`).
- `copilot-cloud-agent-mcp.json` and `copilot-setup-steps.yml`: the Azure DevOps example in GitHub Docs "Configure MCP servers for your repository" (args `-y @azure-devops/mcp <org> -a azcli`; tools `wit_get_work_item`, `wit_get_work_items_batch_by_ids`; job `copilot-setup-steps`, `environment: copilot`, `id-token: write`, `azure/login` pinned to the SHA the docs use, `allow-no-subscriptions: true`; secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` as Agents secrets).
- Agent profile keys `name`, `description`, `tools` (aliases `read`, `search`, `edit`): GitHub Docs "Custom agents configuration". Skill keys `name`, `description`: "Adding agent skills". `applyTo`: "Adding repository custom instructions".
- `.github/release.yml`: keys from "Automatically generated release notes". CODEOWNERS syntax from "About code owners". Mermaid `::: mermaid` + `graph` from the Azure DevOps wiki Markdown guidance.
No secrets in any file.
