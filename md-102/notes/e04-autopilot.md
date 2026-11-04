# Episode 4 — Windows Autopilot: device preparation, modes and ESP

Video: *Windows Autopilot Explained: Device Preparation, Modes and ESP* · Exam area: Manage and maintain devices

## Pinecone scenario

Twenty new laptops arrive at the Amsterdam shop and nobody in IT will touch them. Staff open the box, connect,
and sign in; the join, enrollment, policies, apps and even the switch from Windows Pro to Enterprise happen by
themselves. That is Windows Autopilot, which replaces Pinecone's old MDT image and WDS network deployment.

## Key steps

- [ ] Choose classic Windows Autopilot or Windows Autopilot device preparation (table below).
- [ ] Pro to Enterprise: **subscription activation**. With a Windows Enterprise E3 or E5 license assigned to the
      user, Windows steps up to Enterprise when they sign in, with no reboot.
- [ ] Classic: register devices first. The hardware hash is uploaded by the manufacturer, reseller or
      distributor, or by IT with a CSV file (commands:
      [`commands/e04-autopilot-hardware-hash.ps1`](../commands/e04-autopilot-hardware-hash.ps1)).
- [ ] Deployment profile: **Devices › Device onboarding › Enrollment › Windows Autopilot › Deployment Profiles ›
      Create profile › Windows PC**. Options: Convert all targeted devices to Autopilot (allow 48 hours);
      user-driven or self-deploying; Microsoft Entra joined; hide license terms and privacy settings;
      Administrator or Standard; Allow pre-provisioned deployment; language; device name template. Assign to
      device groups.
- [ ] Device name template: 15 characters or less, letters/numbers/hyphens, not all numbers; `%SERIAL%`,
      `%RAND:x%`. Pinecone: `PC-AMS-%RAND:4%` gives PC-AMS-0142
      ([`commands/e04-e05-device-name-templates.txt`](../commands/e04-e05-device-name-templates.txt)).
- [ ] Enrollment Status Page: **Devices › Device onboarding › Enrollment › Windows tab › Windows Autopilot ›
      Enrollment Status Page**. Show app and profile progress; time-out (60 minutes default); custom error
      message; log collection and diagnostics page (recommended); **Block device use until all apps and profiles
      are installed**; allow reset / use on failure; block until required apps (All or Selected) are installed;
      Install Windows quality updates (adds 20 to 40 minutes).
- [ ] Pre-provisioning technician flow: on the first setup screen press the **Windows key five times** ›
      Windows Autopilot provisioning › check the profile › **Provision** › on success **Reseal**.
- [ ] Windows 11 upgrade: **Reports › Windows updates** › Windows feature update device readiness report (low,
      medium, high risk, replace device) or the Endpoint analytics hardware readiness assessment › feature update
      policy with a Windows 11 version › pilot group first, then broad.
- [ ] Windows Backup for Organizations: backup = settings catalog **Sync your settings › Enable Windows backup**;
      restore = tenant-wide setting under **Devices › Device onboarding › Enrollment** (off by default).

## Decisions

| | Windows Autopilot (classic) | Autopilot device preparation |
|---|---|---|
| Configuration | deployment profile + Enrollment Status Page | one device preparation policy |
| Registration (hardware hash) | required | not needed |
| Join types | Entra join **and hybrid join** | Entra join only |
| Modes | user-driven, pre-provisioning, self-deploying | user-driven; automatic (Windows 365 Cloud PCs) |
| Windows | Windows 10 and 11 | Windows 11 |
| Apps during setup | up to 100 | up to 25 apps and 10 scripts |
| Progress | ESP | its own percentage |
| Grouping | profile assigned to device groups | enrollment time grouping (episode 6) |

| Mode | Use | Notes |
|---|---|---|
| User-driven | a person sets up their own device | device associated with the enrolling user; credentials required |
| Pre-provisioning | arrive with most apps already installed | technician flow (device policies, device-context apps) then user flow; physical TPM 2.0, no VMs; profile must allow it |
| Self-deploying | kiosks, digital signage, shared devices | TPM 2.0 authenticates the device; Entra join only; no primary user; no interaction on Ethernet |

ESP phases: device preparation › device setup (device-targeted) › account setup (user-targeted).

## Exam traps

- Hybrid join, pre-provisioning or self-deploying point to **classic Autopilot**.
- The ESP belongs to classic Autopilot; device preparation shows its own percentage.
- Two profiles on one device: the **oldest** profile wins. Several ESPs: **priority 1** wins; a default ESP
  applies when none is assigned.
- A changed deployment profile only applies after the device is **reset and enrolled again**.
- The name template needs the **Entra join** type; hybrid profiles only get a prefix.
- Self-deploying has no primary user, so user-assigned Company Portal apps don't apply.
- A device with both a Windows 10 and a Windows 11 feature update policy is offered **Windows 11**. Windows 10
  reached end of support on 14 October 2025.
- Windows Backup restore needs Entra join and, with Autopilot, user-driven mode; it doesn't work with hybrid
  join, self-deploying, the pre-provisioning technician flow, or shared devices.
- MDT is retired; Microsoft points to Autopilot instead.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Overview of Windows Autopilot: https://learn.microsoft.com/en-us/autopilot/overview
- Windows subscription activation (Pro to Enterprise): https://learn.microsoft.com/en-us/windows/deployment/windows-subscription-activation
- Registration overview: https://learn.microsoft.com/en-us/autopilot/registration-overview
- Manually register devices (CSV import, hash capture): https://learn.microsoft.com/en-us/autopilot/add-devices
- Compare device preparation and Windows Autopilot: https://learn.microsoft.com/en-us/autopilot/device-preparation/compare
- Device preparation overview: https://learn.microsoft.com/en-us/autopilot/device-preparation/overview
- Automatic mode for Windows 365: https://learn.microsoft.com/en-us/autopilot/device-preparation/tutorial/automatic/automatic-workflow
- Configure Windows Autopilot profiles: https://learn.microsoft.com/en-us/autopilot/profiles
- Pre-provisioned deployment: https://learn.microsoft.com/en-us/autopilot/pre-provision
- Self-deploying mode: https://learn.microsoft.com/en-us/autopilot/self-deploying
- Enrollment Status Page: https://learn.microsoft.com/en-us/intune/device-enrollment/windows/setup-status-page
- Prepare for Windows 11: https://learn.microsoft.com/en-us/windows/whats-new/windows-11-prepare
- Feature update policies: https://learn.microsoft.com/en-us/intune/device-updates/windows/configure-feature-update-policy
- Compatibility reports for Windows updates: https://learn.microsoft.com/en-us/intune/device-updates/windows/monitor-compatibility
- Windows Backup for Organizations: https://learn.microsoft.com/en-us/intune/device-enrollment/windows/enable-backup-restore
- MDT release notes (retired): https://learn.microsoft.com/en-us/intune/configmgr/mdt/release-notes
