# Episode 9 — Intune update rings, Windows Autopatch and Hotpatch

Video: *Intune Update Rings, Windows Autopatch and Hotpatch Explained* · Exam area: Protect devices

## Pinecone scenario

A critical Windows security fix is out, and Pinecone's broad update ring says: wait seven days. Wait, or break
your own rules? Neither: an expedite policy installs that one fix now and leaves the ring alone. The episode
covers every update tool on the exam, for Windows, Apple and Android.

## Key steps

- [ ] **Devices › Windows updates**: tabs Update rings, Feature updates, Quality updates, Driver updates.
- [ ] Update rings: pilot (0 days deferral) and broad (7 days); assign to **device groups**; one ring per device.
      Set active hours, deadlines (2 to 30 days) and grace period (up to 7 days).
- [ ] Feature update policy: pick the Windows version (for example Windows 11, version 24H2). In the ring, set
      the feature update deferral to **0** and **don't pause** feature updates.
- [ ] Urgent fix: **Devices › Windows updates › Quality updates › Create › Expedite policy** › pick one update ›
      assign to the broad ring's device group › restart deadline 0, 1 or 2 days › check **Reports › Windows
      updates › Windows Expedited Update Report**.
- [ ] Windows Autopatch: create an Autopatch group (device groups, Test and Last rings plus rings in between,
      distribution by percentage or assigned group). Don't assign your own rings to Autopatch-managed devices.
- [ ] Hotpatch: on by default for eligible devices; control it with the quality update policy setting **"When
      available, apply without restarting the device"**; check the Hotpatch report.
- [ ] Apple: settings catalog › Declarative Device Management › **Software Update Enforce Latest** (Delay in
      Days, Install Time) or a targeted version with a deadline (iOS 17 / macOS 14 and later).
- [ ] Android (company-owned): device restrictions profile › system update (device default, automatic,
      postponed, maintenance window) + freeze periods; Samsung/Zebra firmware with FOTA.
- [ ] Delivery Optimization: configuration profile › Windows 10 and later › Templates › **Delivery
      Optimization** › download mode.
- [ ] Reports: **Reports › Windows updates** (Summary tab, Windows Feature Update Report, expedite report);
      per-ring check-in and per-setting status; Autopatch reports.

## Decisions

| Tool | Decides |
|---|---|
| Update ring | **when** (deferrals, deadlines, restarts, active hours) |
| Feature update policy | **which version** (devices move up to it, not past it) |
| Quality update policy | monthly cumulative fixes from the cloud |
| Expedite policy | one urgent quality update, past the deferral, for that update only |
| Windows Autopatch | orchestrates Windows, Microsoft 365 Apps, Edge, Teams with groups and rings |
| Hotpatch | monthly security updates without restart in 8 of 12 months |

| Ring setting / action | Range or effect |
|---|---|
| Quality update deferral | 0 to 30 days |
| Feature update deferral | 0 to 365 days |
| Pause | stops feature or quality updates up to 35 days, then expires by itself |
| Resume / Extend | end a pause early / reset it to 35 days |
| Uninstall | roll back the latest update (feature: within the 2 to 60 day uninstall period) |

| Android system update | Behavior |
|---|---|
| Device default | installs on Wi-Fi, charging and idle |
| Automatic | installs right away |
| Postponed | waits 30 days, then asks the user |
| Maintenance window | installs in a time frame you choose |

| Delivery Optimization mode | Peering |
|---|---|
| HTTP only | off |
| LAN (default) | peers on the same network |
| Group | across a group (AD site or Group ID) |
| Internet | adds internet peers |
| Simple | no cloud services at all |

Hotpatch eligibility: Windows 11 24H2 or later, virtualization-based security running, on the latest baseline
(Arm devices need one extra setting). Baseline months (with restart): January, April, July, October.

## Exam traps

- The **ring decides when, the feature update policy decides which version**.
- **Pause is an emergency brake, not a version lock**; a feature update policy even needs feature updates
  unpaused.
- Expedite doesn't change future updates or the ring; a device that already has the update (or a newer one) does
  nothing; installation starts after the next update scan.
- Feature/quality/driver policies need **Entra joined or hybrid joined** devices and diagnostic data at least
  **Required**; Entra registered devices only get ring settings.
- Two rings on one device = conflict.
- Intune never stores updates: devices download from Windows Update (unlike ConfigMgr's WSUS + distribution
  points).
- Autopatch groups take **device** groups, not user groups.
- Apple report trap: **Success means the policy reached the device**, not that it updated; check the OS version.
  Older MDM update policies are deprecated.
- FOTA (Samsung Knox E-FOTA, Zebra LifeGuard OTA) works on dedicated, fully managed and corporate-owned work
  profile devices.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Windows update management overview: https://learn.microsoft.com/en-us/intune/device-updates/windows/
- Update rings: https://learn.microsoft.com/en-us/intune/device-updates/windows/manage-update-rings
- Update ring settings: https://learn.microsoft.com/en-us/intune/device-updates/windows/ref-update-ring-settings
- Feature updates: https://learn.microsoft.com/en-us/intune/device-updates/windows/manage-feature-updates
- Quality updates: https://learn.microsoft.com/en-us/intune/device-updates/windows/manage-quality-updates
- Expedite policies: https://learn.microsoft.com/en-us/intune/device-updates/windows/configure-expedite-policy
- What is Windows Autopatch?: https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/overview/windows-autopatch-overview
- Autopatch groups: https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/deploy/windows-autopatch-groups-overview
- Hotpatch (Intune): https://learn.microsoft.com/en-us/intune/device-updates/windows/configure-hotpatch
- Hotpatch (Autopatch): https://learn.microsoft.com/en-us/windows/deployment/windows-autopatch/manage/windows-autopatch-hotpatch-updates
- Apple update policies: https://learn.microsoft.com/en-us/intune/device-updates/apple/
- Android software updates: https://learn.microsoft.com/en-us/intune/device-updates/android/planning-guide
- Android FOTA: https://learn.microsoft.com/en-us/intune/device-updates/android/manage-fota
- Delivery Optimization in Intune: https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-delivery-optimization-windows
- Delivery Optimization reference: https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization-reference
- Feature update reports: https://learn.microsoft.com/en-us/intune/device-updates/windows/monitor-feature-updates
- ConfigMgr software updates: https://learn.microsoft.com/en-us/intune/configmgr/sum/understand/software-updates-introduction
