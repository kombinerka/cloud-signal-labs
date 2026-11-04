# Episode 7 — Intune remote actions: retire vs wipe vs Fresh Start

Video: *Intune Remote Actions: Retire vs Wipe vs Fresh Start, Device Query, Diagnostics* · Exam area: Manage and maintain devices

## Pinecone scenario

Three devices land on the help desk one morning: a shop laptop stolen in a break-in, a manager's laptop that is
slow and full of preinstalled apps, and a former employee's own phone still holding company email. Three
devices, three buttons. Pick the wrong one and you leak company data or delete someone's family photos.

## Key steps

- [ ] Every action starts at **Devices › All devices › select a device** › action row across the top (some hide
      under the ellipsis). Retire, Wipe and Fresh Start sit under **Remove data**. Status of all actions:
      **Devices › Device actions**.
- [ ] Check prerequisites: device enrolled and online; the action runs at the next check-in; your role needs the
      matching **Remote tasks** permission (for example Remote tasks/Wipe); Multi Admin Approval may require a
      second admin for retire and wipe.
- [ ] Stolen laptop: **Wipe**. If it won't come back, also remove it from Autopilot and Entra ID.
- [ ] Former employee's phone: **Retire**. On an Entra joined Windows device, back up the BitLocker recovery key
      and local admin password first.
- [ ] Slow laptop: **Fresh Start** (Windows only), with **Retain user data on this device**.
- [ ] Security actions: Update Windows Defender security intelligence; Quick scan / Full scan; under **Secure**:
      **BitLocker key rotation** and **Rotate local admin password**. See the new values under **Monitor ›
      Recovery keys** and **Monitor › Local admin password**.
- [ ] Bulk: **Devices › All devices › Bulk device actions** › OS › action › up to **100** devices › Create.
- [ ] Device query: **Devices › Windows › select the device › Monitor › Device query** › KQL › Run
      ([`commands/e07-device-query.kql`](../commands/e07-device-query.kql)).
- [ ] Collect diagnostics: action **Collect diagnostics** › **Monitor › Device diagnostics** › download the zip.
      Turn it off tenant-wide in **Tenant administration › Device diagnostics**.
- [ ] User calls the help desk: **Troubleshooting + support › Troubleshoot** › select the user.

## Decisions

| Situation | Button | What happens |
|---|---|---|
| Personal device, person leaves | **Retire** | company apps, Wi-Fi/VPN profiles, certificates, Intune email profiles removed; photos and personal apps stay; Microsoft 365 Apps stay on Windows; Entra joined Windows is unjoined |
| Lost/stolen, or laptop goes to someone else | **Wipe** | factory reset: personal and corporate data, apps, settings gone |
| Same user, clean Windows | **Fresh Start** | removes mainly OEM preinstalled apps; with Retain user data: stays Entra joined, re-enrolls at sign-in, keeps the home folder |

| Wipe option (Windows) | Effect |
|---|---|
| Keep enrollment state and user account | resets but keeps user data, stays enrolled |
| Continue to wipe even if device loses power | most thorough; can leave some devices unbootable (corporate devices with a recovery plan only) |
| No option | an interrupted wipe tries to roll back |

| Need | Tool |
|---|---|
| One device's live state | device query (KQL, near real time) |
| Logs from a corporate Windows device | collect diagnostics (about 30 minutes, kept 28 days, non-user locations only) |
| Everything about one user | Troubleshooting pane |

| Configuration Manager | Intune |
|---|---|
| client notification: download computer policy | Sync |
| CMPivot | device query |
| Collect client logs | collect diagnostics |

## Exam traps

- **Personal data must stay: retire. Everything must go: wipe. Same user, clean Windows: Fresh Start.**
- Fresh Start without Retain user data returns to out-of-box state, and a personal device is also removed from
  Entra ID and Intune.
- **Sync** forces a check-in now (test a policy without waiting). **Restart** happens within five minutes and the
  user is not notified: sync first, restart only when you must.
- Updating Defender security intelligence downloads definitions; it **does not start a scan**.
- BitLocker key rotation needs a BitLocker policy with **client-driven recovery password rotation** and **save
  recovery information to Microsoft Entra ID**. Rotate after a key was read to a user.
- LAPS rotation needs Entra joined or hybrid joined devices backing up to Entra ID; a manual rotation resets the
  schedule; it is **not a bulk action**.
- Bulk actions include sync, restart, rename, retire, wipe, delete, Autopilot reset, collect diagnostics.
  Wipe, retire and delete count toward **daily tenant limits** and override other pending actions.
- Device query is part of **Advanced Analytics**; needs a corporate-owned Entra joined or hybrid joined Windows
  device, the **Managed devices/Query** permission, and WNS. Copilot in Intune can write the KQL.
- Troubleshooting pane: Help Desk Operator role, plus the collect diagnostics permission to fetch logs. Phones get
  diagnostics through app protection (Outlook, Teams, Edge).

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Device actions overview: https://learn.microsoft.com/en-us/intune/device-management/actions/
- Sync: https://learn.microsoft.com/en-us/intune/device-management/actions/sync
- Restart, Defender actions: https://learn.microsoft.com/en-us/intune/device-security/endpoint-security-devices
- Retire: https://learn.microsoft.com/en-us/intune/device-management/actions/retire
- Wipe: https://learn.microsoft.com/en-us/intune/device-management/actions/wipe
- Fresh Start: https://learn.microsoft.com/en-us/intune/device-management/actions/fresh-start
- BitLocker key rotation: https://learn.microsoft.com/en-us/intune/device-management/actions/rotate-bitlocker-keys
- Encrypt Windows devices with BitLocker: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/encrypt-bitlocker-windows
- Rotate local admin password: https://learn.microsoft.com/en-us/intune/device-management/actions/rotate-local-admin-password
- Windows LAPS policies: https://learn.microsoft.com/en-us/intune/device-security/laps/deploy-policy
- Device query: https://learn.microsoft.com/en-us/intune/advanced-analytics/device-query
- Intune Data Platform schema: https://learn.microsoft.com/en-us/intune/advanced-analytics/ref-data-platform-schema
- Collect diagnostics: https://learn.microsoft.com/en-us/intune/device-management/actions/collect-diagnostics
- Troubleshooting pane: https://learn.microsoft.com/en-us/intune/fundamentals/it-pro-support/help-desk-operators
- Configuration Manager client notification: https://learn.microsoft.com/en-us/MEM/configmgr/core/clients/manage/client-notification
