# MD-102 study index

Companion page for the free **MD-102 Managing and Securing Microsoft 365 Endpoints by using Intune** course on
Cloud Signal (YouTube): one cheat sheet per episode for revision or printing, plus the PowerShell and KQL from
episode 12. Skills measured as of 27 October 2026. Check Microsoft's
[MD-102 study guide](https://learn.microsoft.com/credentials/certifications/resources/study-guides/md-102) for the current outline.

| # | Exam area | Video | Cheat sheet |
|---|---|---|---|
| 1 | Prepare infrastructure | Entra Registered vs Joined vs Hybrid Joined: Start Here for MD-102 | [e01](e01-cheatsheet.png) |
| 2 | Prepare infrastructure | Intune Enrollment Explained: Windows, iPhone, Mac and Android Devices | [e02](e02-cheatsheet.png) |
| 3 | Prepare infrastructure | Intune Roles, Scope Tags and Compliance Policies Explained | [e03](e03-cheatsheet.png) |
| 4 | Manage and maintain | Windows Autopilot Explained: Device Preparation, Modes and ESP | [e04](e04-cheatsheet.png) |
| 5 | Manage and maintain | Windows 365 Cloud PCs in Intune: Provisioning Policies, Networks and Images | [e05](e05-cheatsheet.png) |
| 6 | Manage and maintain | Intune Configuration Profiles: Settings Catalog, Group Policy Migration and Filters | [e06](e06-cheatsheet.png) |
| 7 | Manage and maintain | Intune Suite Add-ons Explained: EPM, Remote Help, Cloud PKI, Tunnel for MAM | [e07](e07-cheatsheet.png) |
| 8 | Manage and maintain | Intune Remote Actions: Retire vs Wipe vs Fresh Start, Device Query, Diagnostics | [e08](e08-cheatsheet.png) |
| 9 | Protect devices | Intune Endpoint Security: BitLocker, ASR Rules, Defender and App Control | [e09](e09-cheatsheet.png) |
| 10 | Protect devices | Intune Update Rings, Windows Autopatch and Hotpatch Explained | [e10](e10-cheatsheet.png) |
| 11 | Manage and secure apps | Intune App Management: Win32 Apps, Microsoft 365 Apps, App Protection vs Configuration | [e11](e11-cheatsheet.png) |
| 12 | Automate, monitor, report | Intune Automation and Monitoring: Graph PowerShell, Copilot Agents, Remediations | [e12](e12-cheatsheet.png) · [code](e12-automation/) |
| P1 | Areas 1–2 | MD-102 Practice Questions: Enrollment, Autopilot and Device Management | [p1](p1-cheatsheet.png) |
| P2 | Areas 3–5 | MD-102 Practice Questions: Endpoint Security, Updates, Apps and Automation | [p2](p2-cheatsheet.png) |

## Episode 12 code

| File | What |
|---|---|
| [`01-find-quiet-devices.ps1`](e12-automation/01-find-quiet-devices.ps1) | Microsoft Graph PowerShell: devices that haven't synced for N days, export, optional sync |
| [`02-export-devices-report.ps1`](e12-automation/02-export-devices-report.ps1) | create a "Devices" export job and download the result |
| [`03-custom-compliance-discovery.ps1`](e12-automation/03-custom-compliance-discovery.ps1) + [`03-custom-compliance-rules.json`](e12-automation/03-custom-compliance-rules.json) | custom compliance (Learn sample; Windows PowerShell 5.1) |
| [`04-remediation-detect-spooler.ps1`](e12-automation/04-remediation-detect-spooler.ps1) / [`05-remediation-fix-spooler.ps1`](e12-automation/05-remediation-fix-spooler.ps1) | a Remediations detection/remediation pair |
| [`06-compliance-by-state.kql`](e12-automation/06-compliance-by-state.kql) | Log Analytics query on IntuneDeviceComplianceOrg |

Validation: cmdlet names, parameters and permission scopes checked against Microsoft Learn; scripts were not run
against a tenant. Use least-privilege scopes and test in a pilot group first.
