---
applyTo: ".github/workflows/**/*.yml"
---
# GitHub Actions rules for Copilot (Pinecone)

- Pin third-party actions to a specific commit SHA.
- Give GITHUB_TOKEN only the permissions the workflow needs (set `permissions:` explicitly).
- Never put credentials in workflow files; use secrets, or OIDC for Azure (azure/login).
- Set `timeout-minutes` on every job.
- Use `push`, `pull_request` and `workflow_dispatch` triggers with branch and path filters; avoid building docs-only changes.
- Give workflows, jobs and steps descriptive names.
