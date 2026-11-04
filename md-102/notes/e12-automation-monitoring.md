# Episode 12 — Intune automation and monitoring: Graph PowerShell, Copilot agents, Remediations

Video: *Intune Automation and Monitoring: Graph PowerShell, Copilot Agents, Remediations* · Exam area: Optimize endpoint operations by using automation, monitoring, and reporting

## Pinecone scenario

Monday morning, the manager asks which of the 300 laptops haven't checked in with Intune for two weeks.
Clicking through the admin center takes an hour; Microsoft Graph answers in seconds. Then: custom compliance for
the kiosks, Security Copilot agents, Endpoint analytics, Remediations, reports and service health.

## Key steps

- [ ] Install the SDK once: `Install-Module Microsoft.Graph` (full command and scripts in
      [`e12-automation/`](../e12-automation/)).
- [ ] `Connect-MgGraph -Scopes` with the **least privileged** scope: reading devices =
      `DeviceManagementManagedDevices.Read.All` (delegated). Unattended scripts: app-only access through an app
      registration. Unsure of the scope? `Find-MgGraphCommand`.
- [ ] `Get-MgDeviceManagementManagedDevice -All` › keep devices whose last sync date is older than 14 days ›
      export to CSV ([`01-find-quiet-devices.ps1`](../e12-automation/01-find-quiet-devices.ps1)).
      `Sync-MgDeviceManagementManagedDevice` needs `DeviceManagementManagedDevices.PrivilegedOperations.All`.
- [ ] Custom compliance: **Endpoint security › Device compliance › Scripts › Add** the discovery script (returns
      one line of JSON with `ConvertTo-Json -Compress`) › in a normal compliance policy add the script and the
      **JSON rules file** (setting, operator such as GreaterEquals, data type, operand, Company Portal message)
      ([`03-custom-compliance-discovery.ps1`](../e12-automation/03-custom-compliance-discovery.ps1),
      [`03-custom-compliance-rules.json`](../e12-automation/03-custom-compliance-rules.json)).
- [ ] Security Copilot agents: **Agents** node in the admin center (needs Security Copilot with security compute
      units). Vulnerability Remediation Agent (preview): review the ranked suggestions, apply the fix with Intune,
      mark it as applied.
- [ ] Endpoint analytics: **Reports › Analytics › Endpoint analytics** › Intune creates a data collection policy ›
      devices need a restart to report everything › save your own baseline if needed.
- [ ] Remediations: **Devices › Manage devices › Scripts and remediations** › detection script + optional
      remediation script › assign to a group with a schedule (once, hourly, daily) › device status view / export
      ([`04-remediation-detect-spooler.ps1`](../e12-automation/04-remediation-detect-spooler.ps1),
      [`05-remediation-fix-spooler.ps1`](../e12-automation/05-remediation-fix-spooler.ps1)).
- [ ] Exports: in the portal, or via the Graph export jobs API (post report name + **columns**, wait for
      completed, download) ([`02-export-devices-report.ps1`](../e12-automation/02-export-devices-report.ps1)).
- [ ] Workbooks: **Reports › Diagnostics settings** › send audit logs, operational logs, device compliance, Intune
      devices to Log Analytics › query with KQL
      ([`06-compliance-by-state.kql`](../e12-automation/06-compliance-by-state.kql)) › Azure Monitor workbooks.
- [ ] Health: **Tenant administration › Tenant status** (tenant details, connector status, service health and
      message center) before you open a ticket.
- [ ] Alerts: compliance actions for noncompliance (email user + extra recipients); Windows 365 alert rules under
      Tenant administration; Log Analytics alerts on any Intune log.

## Decisions

| Need | Tool |
|---|---|
| Answer a question about many devices | Microsoft Graph PowerShell (Get, Update, Sync) |
| A compliance check Intune doesn't have | custom compliance (discovery script + JSON rules) |
| Find and fix a recurring problem | Remediations (detection + remediation script) |
| Slow startups, crashing apps | Endpoint analytics (startup performance, app reliability) |
| Is it Microsoft's problem? | Tenant status: service health and message center |

| Endpoint analytics metric | Meaning |
|---|---|
| Score | 0 to 100; needs at least 5 devices reporting |
| Startup score | boot score (power-on to sign-in) + sign-in score (sign-in to responsive desktop) |
| Application reliability | app crashes; mean time to failure = usage time / crashes |
| Baseline | built-in = median of all organizations; regressed when below by more than the threshold (10% default) |

| Report focus area | |
|---|---|
| Operational, organizational, historical, specialist | filter, columns, export; Graph export jobs for automation |

| Configuration Manager | Intune |
|---|---|
| Run Scripts | Remediations |
| configuration baselines | custom compliance |
| queries and console reports | Graph PowerShell and Intune reports |

## Exam traps

- **Remediation runs only when detection exits with 1** (issue found).
- Remediations need Windows Enterprise E3/E5, Education A3/A5, or Windows VDA per user. Two built-in packages
  (for example restart the Office Click-to-Run service). The on-demand **Run remediation** device action is
  preview.
- Remediation results are not compliance settings; **custom compliance** results count in Conditional Access.
- Custom compliance: one discovery script per policy; on Windows the IME runs it every **8 hours**, so a fixed
  device can take up to 8 hours to show compliant. Windows, macOS, Linux.
- Least privilege: a read-only script gets `.Read.All`, not `.ReadWrite.All`. The Graph API for Intune needs an
  active Intune license in the tenant.
- **Agents investigate and suggest; a human administrator decides.** The agent runs as its own agent identity
  with delegated permissions. The Change Review Agent was retired on 31 August 2026. Copilot in Intune can
  summarize and compare devices, limited by your roles and scope tags.
- Export jobs: **always specify the columns**; don't automate around default columns.
- Log Analytics latency: audit and operational logs right away; compliance and device data up to **48 hours**.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Install the Microsoft Graph PowerShell SDK: https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0
- Get started with the SDK: https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0
- Get-MgDeviceManagementManagedDevice: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devicemanagement/get-mgdevicemanagementmanageddevice?view=graph-powershell-1.0
- Get managedDevice (permissions): https://learn.microsoft.com/en-us/graph/api/intune-devices-manageddevice-get?view=graph-rest-1.0
- Sync-MgDeviceManagementManagedDevice: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devicemanagement/sync-mgdevicemanagementmanageddevice?view=graph-powershell-1.0
- Custom compliance: https://learn.microsoft.com/en-us/intune/device-security/compliance/custom-settings · https://learn.microsoft.com/en-us/intune/device-security/compliance/create-custom-script · https://learn.microsoft.com/en-us/intune/device-security/compliance/create-custom-json
- Security Copilot agents in Intune: https://learn.microsoft.com/en-us/intune/copilot/agents/
- Vulnerability Remediation Agent: https://learn.microsoft.com/en-us/intune/copilot/agents/vulnerability-remediation-agent
- Change Review Agent: https://learn.microsoft.com/en-us/intune/copilot/agents/change-review-agent
- Copilot device troubleshooting: https://learn.microsoft.com/en-us/intune/copilot/troubleshoot-devices
- Endpoint analytics: https://learn.microsoft.com/en-us/intune/endpoint-analytics/ · https://learn.microsoft.com/en-us/intune/endpoint-analytics/configure · https://learn.microsoft.com/en-us/intune/endpoint-analytics/scores
- Startup performance: https://learn.microsoft.com/en-us/intune/endpoint-analytics/startup-performance
- Application reliability: https://learn.microsoft.com/en-us/intune/endpoint-analytics/app-reliability
- Remediations: https://learn.microsoft.com/en-us/intune/device-management/tools/deploy-remediations
- Intune reports: https://learn.microsoft.com/en-us/intune/device-management/reports/overview
- Export reports with Graph: https://learn.microsoft.com/en-us/intune/device-management/reports/export-graph-apis
- Route logs to Azure Monitor: https://learn.microsoft.com/en-us/intune/governance/integrate-azure-monitor
- Tenant status: https://learn.microsoft.com/en-us/intune/governance/tenant-status
- Actions for noncompliance: https://learn.microsoft.com/en-us/intune/device-security/compliance/configure-noncompliance-actions
- Windows 365 alerts: https://learn.microsoft.com/en-us/windows-365/enterprise/alerts
