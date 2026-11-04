# MD-102 study index

▶ **[Watch the full course playlist on YouTube](https://www.youtube.com/playlist?list=PLJ7iVS5Fohb4)**

Companion page for the free **MD-102 Managing and Securing Microsoft 365 Endpoints by using Intune** course on
Cloud Signal (YouTube): one cheat sheet per episode for revision or printing, plus the PowerShell and KQL from
episode 12. Skills measured as of 27 October 2026. Check Microsoft's
[MD-102 study guide](https://learn.microsoft.com/credentials/certifications/resources/study-guides/md-102) for the current outline.

Updated for the MD-102 skills outline of 27 October 2026

The downloadable study package: [study notes](#study-notes) per episode, both [practice sets explained](#practice-sets-explained)
question by question, and the [exact syntax](#commands) the episodes teach. All names and values are fictional (the
running example is Pinecone, a retailer with shops in several cities).

| # | Exam area | Video | Cheat sheet |
|---|---|---|---|
| 1 | Prepare infrastructure | [Entra Registered vs Joined vs Hybrid Joined: Start Here for MD-102](https://www.youtube.com/watch?v=qE6mYgmOhlw) | [e01](e01-cheatsheet.png) |
| 2 | Prepare infrastructure | [Intune Enrollment Explained: Windows, iPhone, Mac and Android Devices](https://www.youtube.com/watch?v=XoLTtxjwH8g) | [e02](e02-cheatsheet.png) |
| 3 | Prepare infrastructure | [Intune Roles, Scope Tags and Compliance Policies Explained](https://www.youtube.com/watch?v=lnNszETbUzQ) | [e03](e03-cheatsheet.png) |
| 4 | Manage and maintain | [Windows Autopilot Explained: Device Preparation, Modes and ESP](https://www.youtube.com/watch?v=-ph6gtR4K3E) | [e04](e04-cheatsheet.png) |
| 5 | Manage and maintain | [Windows 365 Cloud PCs in Intune: Provisioning Policies, Networks and Images](https://www.youtube.com/watch?v=4lyl-LXVEhM) | [e05](e05-cheatsheet.png) |
| 6 | Manage and maintain | [Intune Configuration Profiles: Settings Catalog, Group Policy Migration and Filters](https://www.youtube.com/watch?v=8A8s547aI-A) | [e06](e06-cheatsheet.png) |
| 7 | Manage and maintain | [Intune Suite Add-ons Explained: EPM, Remote Help, Cloud PKI, Tunnel for MAM](https://www.youtube.com/watch?v=X86LEUnwg6Y) | [e07](e07-cheatsheet.png) |
| 8 | Manage and maintain | [Intune Remote Actions: Retire vs Wipe vs Fresh Start, Device Query, Diagnostics](https://www.youtube.com/watch?v=sjuYawuerSk) | [e08](e08-cheatsheet.png) |
| 9 | Protect devices | [Intune Endpoint Security: BitLocker, ASR Rules, Defender and App Control](https://www.youtube.com/watch?v=d-hCswQVRK0) | [e09](e09-cheatsheet.png) |
| 10 | Protect devices | [Intune Update Rings, Windows Autopatch and Hotpatch Explained](https://www.youtube.com/watch?v=R93icuC6c4M) | [e10](e10-cheatsheet.png) |
| 11 | Manage and secure apps | [Intune App Management: Win32 Apps, Microsoft 365 Apps, App Protection vs Configuration](https://www.youtube.com/watch?v=cU17i7OTpB8) | [e11](e11-cheatsheet.png) |
| 12 | Automate, monitor, report | [Intune Automation and Monitoring: Graph PowerShell, Copilot Agents, Remediations](https://www.youtube.com/watch?v=Scv_AiGfSvU) | [e12](e12-cheatsheet.png) · [code](e12-automation/) |
| P1 | Areas 1–2 | [MD-102 Practice Questions: Enrollment, Autopilot and Device Management](https://www.youtube.com/watch?v=ZymkHR-tJKY) | [p1](p1-cheatsheet.png) |
| P2 | Areas 3–5 | [MD-102 Practice Questions: Endpoint Security, Updates, Apps and Automation](https://www.youtube.com/watch?v=cQcm6O8A_js) | [p2](p2-cheatsheet.png) |

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

## Study notes

One page per episode in [`notes/`](notes/): the Pinecone scenario, the key steps as a checklist with the exact
Intune and Entra admin center paths, decision tables, exam traps, and the Microsoft Learn sources.

The notes follow the current course order. Episodes 7 to 11 were reordered (7 remote actions, 8 endpoint security,
9 updates, 10 apps, 11 Intune Suite add-ons); the table above still lists the earlier upload order.

| # | Exam area | Notes |
|---|---|---|
| 1 | Prepare infrastructure | [Device identity: registered, joined, hybrid joined; device groups](notes/e01-device-identity.md) |
| 2 | Prepare infrastructure | [Enrollment: Windows, Apple, Android, troubleshooting](notes/e02-enrollment.md) |
| 3 | Prepare infrastructure | [Roles, scope tags, Multi Admin Approval, compliance, Windows Hello, LAPS](notes/e03-roles-compliance.md) |
| 4 | Manage and maintain | [Windows Autopilot and device preparation, modes, ESP, Windows 11 upgrades](notes/e04-autopilot.md) |
| 5 | Manage and maintain | [Windows 365 Cloud PCs: provisioning policies, networks, images](notes/e05-windows-365.md) |
| 6 | Manage and maintain | [Configuration profiles, Group Policy migration, filters, enrollment time grouping](notes/e06-configuration-profiles.md) |
| 7 | Manage and maintain | [Remote actions: retire, wipe, Fresh Start, device query, diagnostics](notes/e07-remote-actions.md) |
| 8 | Protect devices | [Endpoint security: BitLocker, antivirus, ASR, baselines, Defender, App Control](notes/e08-endpoint-security.md) |
| 9 | Protect devices | [Updates: rings, feature and quality updates, Autopatch, Hotpatch, Apple, Android](notes/e09-updates.md) |
| 10 | Manage and secure apps | [Apps: Win32, Microsoft 365 Apps, stores, app protection vs configuration](notes/e10-apps.md) |
| 11 | Manage and maintain | [Intune Suite add-ons: EPM, Enterprise App Catalog, Remote Help, Cloud PKI, Tunnel for MAM](notes/e11-intune-suite.md) |
| 12 | Automate, monitor, report | [Graph PowerShell, custom compliance, Copilot agents, Endpoint analytics, Remediations](notes/e12-automation-monitoring.md) |

## Practice sets explained

Every question with its options, the correct answer, why it's right, why each other option is wrong, and the
episode to rewatch. Original questions written against the skills outline (not exam dumps).

| Set | Covers | Explained |
|---|---|---|
| P1 | Areas 1–2: identity, enrollment, Autopilot, Windows 365, profiles, EPM, remote actions | [practice/p1-explained.md](practice/p1-explained.md) |
| P2 | Areas 3–5: endpoint security, updates, apps, automation and monitoring | [practice/p2-explained.md](practice/p2-explained.md) |

## Commands

Small files with the exact syntax episodes 1 to 11 teach, in [`commands/`](commands/). Each file starts with what it
does, where to paste or run it, and the least-privilege role or permission it needs.

| File | Episode | What |
|---|---|---|
| [`e01-dynamic-device-group-rules.txt`](commands/e01-dynamic-device-group-rules.txt) | 1 | Entra dynamic device group rules: OS, ownership, Autopilot ZTDId, join type |
| [`e04-autopilot-hardware-hash.ps1`](commands/e04-autopilot-hardware-hash.ps1) | 4 | capture the hardware hash to CSV, or upload it with `-Online` |
| [`e04-e05-device-name-templates.txt`](commands/e04-e05-device-name-templates.txt) | 4, 5 | Autopilot and Windows 365 device name templates (`%SERIAL%`, `%RAND:x%`) |
| [`e06-assignment-filter-rules.txt`](commands/e06-assignment-filter-rules.txt) | 6 | Intune assignment filter rules (device name, ownership, manufacturer, OS version) |
| [`e07-device-query.kql`](commands/e07-device-query.kql) | 7 | device query: encryption status, a service, BIOS |
| [`e07-e08-bitlocker-settings.txt`](commands/e07-e08-bitlocker-settings.txt) | 7, 8 | BitLocker settings for silent encryption and key rotation |
| [`e10-win32-package.ps1`](commands/e10-win32-package.ps1) | 10 | Win32 Content Prep Tool: pack a setup folder into .intunewin |
| [`e10-win32-detection-label-tool.ps1`](commands/e10-win32-detection-label-tool.ps1) | 10 | custom detection script for a Win32 app |
| [`e10-office-deployment-tool.txt`](commands/e10-office-deployment-tool.txt) | 10 | Office Deployment Tool command line |

Validation: syntax, cmdlets, parameters, roles and permissions checked against Microsoft Learn; not run against a
tenant. The PowerShell files were not parse-checked (no PowerShell in the authoring environment). Episode 12's
Graph PowerShell is in [`e12-automation/`](e12-automation/) above.

## Which exam is for you?

- **MD-102** (Microsoft 365 Certified: Endpoint Administrator Associate) is endpoint and device administration:
  Intune, Windows Autopilot, compliance, apps and updates. This course.
  [Study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102) ·
  [certification](https://learn.microsoft.com/en-us/credentials/certifications/modern-desktop/)
- **MS-102** (Microsoft 365 Administrator) is Microsoft 365 tenant administration. It retires on
  30 November 2026. [Exam page](https://learn.microsoft.com/en-us/credentials/certifications/exams/ms-102/)
- **AB-650** (Administering Microsoft 365 and AI Services) leads to the Microsoft 365 Certified: Microsoft 365 and
  AI Services Administrator Associate; it is currently in beta.
  [Exam page](https://learn.microsoft.com/en-us/credentials/certifications/exams/ab-650/) ·
  [study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ab-650)
