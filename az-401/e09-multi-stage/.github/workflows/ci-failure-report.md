---
# Agentic workflow (public preview). Compile with: gh aw compile
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [main]

permissions:
  contents: read
  actions: read
  issues: read
  pull-requests: read
  copilot-requests: write

network: defaults

tools:
  github:
    toolsets: [default, actions]

safe-outputs:
  create-issue:

---

# CI failure report

If the triggering CI run succeeded, stop and do nothing.

If it failed, read the failed job logs and the commits in the run.

Create one GitHub issue with:

- Which job and step failed, with a link to the run.
- The most likely cause, quoting the relevant log lines.
- Whether it looks like a flaky test or a real regression.
- One or two suggested next steps for the maintainers.

Keep it short. Do not guess when the logs do not show the cause.
