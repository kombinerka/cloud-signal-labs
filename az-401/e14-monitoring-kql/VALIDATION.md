# Validation (2026-10-16)

Files: `service-connection-changes.kql`, `audit-events-per-day.kql`, `pat-created-alert.kql`.

No KQL parser is installed in this environment, so the queries were checked by hand against Microsoft Learn:
- Operators and syntax only from "Get started with log queries in Azure Monitor"
  (https://learn.microsoft.com/en-us/azure/azure-monitor/logs/get-started-queries): `where TimeGenerated > ago(...)`,
  `project`, `summarize count() by ...`, `bin(TimeGenerated, ...)`, `sort by ... desc`.
- Table and column names from the AzureDevOpsAuditing reference
  (https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azuredevopsauditing): TimeGenerated,
  OperationName, ActorDisplayName, ActorUPN, ProjectName, Details.
- Operation values from "Auditing events list" (https://learn.microsoft.com/en-us/azure/devops/organizations/audit/auditing-events?view=azure-devops):
  `Library.ServiceConnectionModified`, `Token.PatCreateEvent`.

Not verified: that OperationName holds exactly these action IDs (the table reference doesn't list column values).
Run each query once in your workspace before using it in an alert. Not run against a live workspace.
