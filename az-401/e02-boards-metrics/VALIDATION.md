# Validation (2026-10-16)

```
python3 -c "import json,sys; json.load(open(sys.argv[1]))" .vscode/mcp.json   # OK
```

- `.vscode/mcp.json`: parses as JSON. Server shapes, URLs and headers (`X-MCP-Toolsets`, `X-MCP-Readonly`) taken from "Set up the remote Azure DevOps MCP Server" (Microsoft Learn) and `github/github-mcp-server` docs/remote-server.md. Toolset names `wit`, `work` (Azure DevOps) and `issues`, `pull_requests` (GitHub) are from those pages.
- `active-bugs-30d.wiql`: no offline WIQL validator exists; fields and macros (`[System.TeamProject]`, `[System.WorkItemType]`, `[System.State]`, `[System.CreatedDate]`, `@project`, `@Today - 30`) checked against the WIQL syntax reference. Not executed against a live organization.
