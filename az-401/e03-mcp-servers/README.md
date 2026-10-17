# AZ-401 Episode 3 — Agents, skills, loops and MCP servers

Files shown in the episode (Pinecone and `pinecone` / `pinecone-gear` are fictional placeholders):

| File | What it is |
|---|---|
| `.vscode/mcp.json` | VS Code: remote Azure DevOps MCP Server (work items + wiki, read-only) and remote GitHub MCP server (read-only). Interactive sign-in, no secrets. |
| `copilot-cloud-agent-mcp.json` | Paste into the repository's Settings > Copilot > MCP servers ("MCP configuration") for Copilot cloud agent: local Azure DevOps MCP server, two work item tools only. |
| `.github/workflows/copilot-setup-steps.yml` | Azure login with OIDC in the `copilot` environment before the cloud agent starts. |
| `.github/copilot-instructions.md`, `.github/instructions/bicep.instructions.md` | Repository-wide and path-specific custom instructions. |
| `.github/agents/docs-writer.agent.md` | Custom agent limited to read, search and edit tools. |
| `.github/skills/release-notes/SKILL.md` | Agent skill loaded when relevant. |
| `.github/release.yml` | Categories for automatically generated release notes. |
| `.github/CODEOWNERS` | Code owners; pair with "Require review from Code Owners". |
| `wiki/Release-flow.md` | Azure DevOps wiki page with a Mermaid diagram (`graph`, not `flowchart`). |
