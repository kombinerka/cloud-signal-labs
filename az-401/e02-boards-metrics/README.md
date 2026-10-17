# AZ-401 Episode 2 — Flow of work, traceability and success metrics

Files shown in the episode (Pinecone is a fictional example; the Azure DevOps organization `pinecone` is a placeholder):

- `active-bugs-30d.wiql` — WIQL query: active bugs created in the last 30 days in the current project.
- `.vscode/mcp.json` — VS Code MCP configuration for metric questions in GitHub Copilot agent mode: the remote Azure DevOps MCP Server (work item and work toolsets, read-only) and the remote GitHub MCP server (issues and pull requests toolsets, read-only). Both sign in interactively (Microsoft Entra ID / GitHub OAuth); no secrets in the file.

Linking commits and pull requests to Azure Boards: write `AB#<id>` in a commit message, PR description or issue description; `Fixes AB#<id>` moves the item to its first Resolved (or Completed) state when the PR merges into the default branch.
