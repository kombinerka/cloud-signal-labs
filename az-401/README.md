# AZ-401 study index

▶ **[Watch the full course playlist on YouTube](https://www.youtube.com/playlist?list=PLHenYRWIBdds)**

Companion page for the free **AZ-401 Designing and Implementing Microsoft Agentic DevOps Solutions** course on Cloud Signal (YouTube): one cheat sheet per episode for revision or printing, plus the pipeline, Bicep, Terraform, KQL and Git files the episodes show.

**AZ-401 is in beta.** The course follows the skills outline updated 13 October 2026; the outline can still change, and several tools it covers are in preview. Check Microsoft's [AZ-401 study guide](https://learn.microsoft.com/credentials/certifications/resources/study-guides/az-401) and the [exam page](https://learn.microsoft.com/credentials/certifications/exams/az-401/) for the current state.

All names and values are fictional (the running example is Pinecone, an online hiking-gear shop). The code is validated (YAML parsed, `bicep build`, `terraform fmt -check` + `terraform validate`; see each folder's `VALIDATION.md`), not deployed. Secrets always come from variables or Key Vault.

Animated versions (where an episode has a flow) loop in the browser; the static PNG next to it is the one to print.

## Processes, collaboration and source control

| # | Video | Cheat sheet | Code |
|---|---|---|---|
| 1 | [AZ-401 Explained: Agentic DevOps Exam, Skills and What Changed vs AZ-400](https://www.youtube.com/watch?v=k0UPeTkWT6A) | [static](e01-cheatsheet.png) | — |
| 2 | [Azure Boards Traceability and DevOps Metrics: AB# Links, Lead vs Cycle Time](https://www.youtube.com/watch?v=5JXTPpjfUFU) | [static](e02-cheatsheet.png) · [animated](e02-cheatsheet-animated.png) | [e02-boards-metrics](e02-boards-metrics/) |
| 3 | [Azure DevOps and GitHub MCP Servers, Copilot Agents and Skills](https://www.youtube.com/watch?v=VqAU4TEmO9c) | [static](e03-cheatsheet.png) | [e03-mcp-servers](e03-mcp-servers/) |
| 4 | [Branching Strategies, Branch Policies vs Branch Protection Rules, and Copilot Guardrails](https://www.youtube.com/watch?v=Gv5nq-fomHw) | [static](e04-cheatsheet.png) | [e04-branching](e04-branching/) |
| 5 | [Repository Permissions, Tags, Git Hooks, Azure DevOps to GitHub Migration, and Cleaning History](https://www.youtube.com/watch?v=_vLuVWs5VEs) | [static](e05-cheatsheet.png) | [e05-repositories](e05-repositories/) |

## Packages, testing and pipelines

| # | Video | Cheat sheet | Code |
|---|---|---|---|
| 6 | [Azure Artifacts vs GitHub Packages, Feeds, Views and SemVer vs CalVer](https://www.youtube.com/watch?v=7DLv7UwlaeY) | [static](e06-cheatsheet.png) · [animated](e06-cheatsheet-animated.png) | [e06-packages](e06-packages/) |
| 7 | [Testing Strategy, Code Coverage and Quality Gates with Copilot and MCP](https://www.youtube.com/watch?v=kV0MvH5aqqc) | [static](e07-cheatsheet.png) | [e07-testing](e07-testing/) |
| 8 | [Azure Pipelines vs GitHub Actions: Agents, Runners and Triggers](https://www.youtube.com/watch?v=RCOBtdGY35g) | [static](e08-cheatsheet.png) | [e08-pipelines-runners](e08-pipelines-runners/) |
| 9 | [Multi-Stage Pipelines, Templates and Approvals (+ GitHub Agentic Workflows)](https://www.youtube.com/watch?v=Uex8sqPvnqs) | [static](e09-cheatsheet.png) | [e09-multi-stage](e09-multi-stage/) |
| 10 | [Blue-Green vs Canary vs Rings: Deployment Strategies for AZ-401](https://www.youtube.com/watch?v=zWE2dQKNfo0) | [static](e10-cheatsheet.png) · [animated](e10-cheatsheet-animated.png) | [e10-deployments](e10-deployments/) |
| 11 | [Bicep vs Terraform, Config Management and Pipeline Health](https://www.youtube.com/watch?v=0JYR9CSq2Ss) | [static](e11-cheatsheet.png) | [e11-iac-pipeline-health](e11-iac-pipeline-health/) |

## Security and instrumentation

| # | Video | Cheat sheet | Code |
|---|---|---|---|
| 12 | [Secretless Deployments: Managed Identity, OIDC and Pipeline Tokens](https://www.youtube.com/watch?v=eKAoKVfrI30) | [static](e12-cheatsheet.png) · [animated](e12-cheatsheet-animated.png) | [e12-secretless-identity](e12-secretless-identity/) |
| 13 | [Keep Secrets Out of Pipeline Logs: Key Vault and GitHub Advanced Security](https://www.youtube.com/watch?v=S6poo1x4ljU) | [static](e13-cheatsheet.png) | [e13-secrets-scanning](e13-secrets-scanning/) |
| 14 | [Monitor Azure DevOps and GitHub: Dashboards, Alerts and Your First KQL](https://www.youtube.com/watch?v=svCKdKxH-XQ) | [static](e14-cheatsheet.png) | [e14-monitoring-kql](e14-monitoring-kql/) |
| 15 | [Azure SRE Agent vs Copilot Observability Agent: AI for Incidents and Tracing](https://www.youtube.com/watch?v=Lm-XlNCHJLI) | [static](e15-cheatsheet.png) | — |

## Practice sets

Original questions written against the skills outline (not exam dumps). The sheets summarise the topics and the distinctions that decide the answers, not the questions themselves.

| Set | Video | Cheat sheet |
|---|---|---|
| P1 | [AZ-401 Practice Questions: Processes, Source Control, Packages and Testing (15 Questions)](https://www.youtube.com/watch?v=MSF7Vp1LMRs) | [static](p1-cheatsheet.png) |
| P2 | [AZ-401 Practice Questions: Pipelines, Deployments and IaC (15 Questions)](https://www.youtube.com/watch?v=-WIx3--yR-g) | [static](p2-cheatsheet.png) |
| P3 | [AZ-401 Practice Questions: Security, Compliance and Instrumentation (15 Questions)](https://www.youtube.com/watch?v=6vEJX_nQfyE) | [static](p3-cheatsheet.png) |
