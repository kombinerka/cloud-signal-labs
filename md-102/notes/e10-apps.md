# Episode 10 — Intune app management: Win32, Microsoft 365 Apps, app protection vs configuration

Video: *Intune App Management: Win32 Apps, Microsoft 365 Apps, App Protection vs Configuration* · Exam area: Manage and secure applications

## Pinecone scenario

The label tool for the new shop printers must reach every shop laptop by Monday, with nobody clicking Next. And
a sales rep copies a customer list from Outlook on her own, never-enrolled iPhone into a personal notes app. By
the end: the tool is shipped and the paste is stopped.

## Key steps

- [ ] **Apps › All apps › Create** › pick the app type (store, LOB, Win32, Microsoft 365 Apps, Managed Google
      Play...).
- [ ] Win32: pack the setup folder with the **Microsoft Win32 Content Prep Tool**
      (`IntuneWinAppUtil -c .\label -s .\label\setup.exe -o .\out`;
      [`commands/e10-win32-package.ps1`](../commands/e10-win32-package.ps1)) › Windows app (Win32) › upload the
      .intunewin › **Program** (silent install and uninstall commands) › **Requirements** (architecture, minimum
      Windows) › **Detection rules** (at least one: MSI product code, file, registry, custom script;
      [`commands/e10-win32-detection-label-tool.ps1`](../commands/e10-win32-detection-label-tool.ps1)) ›
      dependencies / supersedence › **Assignments: Required** = shop laptops group.
- [ ] Microsoft Store app: **Microsoft Store app (new)** › search the store › install behavior System or User.
- [ ] Microsoft 365 Apps: app type **Microsoft 365 Apps › Windows 10 and later** (configuration designer or
      XML), or the **Office Deployment Tool** yourself (`setup.exe /configure` + XML;
      [`commands/e10-office-deployment-tool.txt`](../commands/e10-office-deployment-tool.txt)), or the
      **Microsoft 365 Apps admin center** (config.office.com: Office Customization Tool, Cloud Policy).
- [ ] Apple volume purchase: buy in **Apple Business Manager › Apps and Books** › download the location token ›
      **Tenant administration › Connectors and tokens › Apple VPP tokens** (valid one year) › assign with device
      or user licensing.
- [ ] Android: connect **Managed Google Play** › approve apps in the store view inside Intune › Sync (also private
      apps and web links).
- [ ] Quiet Time (under Apps): mute Outlook email and Teams notifications on iOS/Android for a date range or
      chosen days/hours.
- [ ] Troubleshoot: **Apps › All apps › the app** (device/user install status); **Troubleshooting + support** ›
      user › Managed Apps; Win32 logs under ProgramData\Microsoft\IntuneManagementExtension\Logs
      (**AppWorkload.log**); Collect logs from the app's installation details.
- [ ] App protection: **Apps › Protection › Create policy** › iOS/iPadOS or Android › target apps (for example
      core Microsoft apps: Outlook, Teams, OneDrive) › data protection (no save copies, no cut/copy/paste to
      unprotected apps) › access requirements (PIN, fingerprint) › conditional launch › assign to **user groups**
      (a filter can target only unmanaged devices).
- [ ] Conditional Access (Microsoft Entra admin center): platforms Android and iOS › Grant **Require app
      protection policy** › report-only first › On. Deploy app protection policies before the CA policy.
- [ ] App configuration: **Apps › Configuration › Create** › Managed devices or Managed apps.

## Decisions

| App family | Who updates it | Examples |
|---|---|---|
| Store app | the store provider | Microsoft Store, App Store, Google Play |
| Line-of-business (LOB) | you upload a new file each time | MSI, APPX, MSIX |
| Win32 | you (.intunewin; supersedence for updates) | classic setup.exe |

| Assignment | Effect |
|---|---|
| Required | installs on the devices in the group |
| Available | appears in the Company Portal; users install it |
| Uninstall | removes it |

| Apple VPP license | Belongs to | Sign-in |
|---|---|---|
| Device | the device (one license per device) | no App Store sign-in |
| User | the user (up to five devices) | each user signs in with their own Apple account |

| | App protection (MAM) | App configuration |
|---|---|---|
| Job | **protects the data** inside the app | **supplies settings** to the app (port, language, branding, work account) |
| Enrollment | not needed | Managed devices type: enrolled; Managed apps type: Intune App SDK, enrolled or not |

| Conditional Access grant | Needs |
|---|---|
| Require device to be marked as compliant | an enrolled device |
| Require app protection policy | no enrollment; broker app (Authenticator on iOS, Company Portal on Android) |

| Configuration Manager | Intune Win32 app |
|---|---|
| deployment type | Program page |
| detection method | detection rule |
| Software Center | Company Portal |
| distribution point | Intune cloud (downloaded by the Intune Management Extension) |

## Exam traps

- Company data on a phone that is **not enrolled**: **app protection policy**. It applies only to the work
  account; selective wipe removes company data, not photos.
- MSI needing **more than one command-line argument**: use Win32, not LOB.
- Mixing Win32 and LOB apps can fail during **classic Autopilot**; Autopilot device preparation supports the mix.
- Microsoft 365 Apps tracked by the **ESP**: deploy as a **Win32 app** (the built-in type can collide with other
  installs and fail the ESP).
- Cloud Policy applies Office settings to **users**, even on devices that aren't domain joined or managed.
- **Require approved client app** was retired at the end of June 2026; policies using it are read-only. Use
  Require app protection policy.
- Microsoft Store and Android store apps deployed as **Available don't report install status**.
- The Win32 installer must run **silently**; the Intune Management Extension runs it.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Add apps to Intune: https://learn.microsoft.com/en-us/intune/app-management/deployment/
- Windows LOB apps: https://learn.microsoft.com/en-us/intune/app-management/deployment/add-lob-windows
- Microsoft Store apps: https://learn.microsoft.com/en-us/intune/app-management/deployment/add-microsoft-store
- Prepare a Win32 app: https://learn.microsoft.com/en-us/intune/app-management/deployment/create-win32-package
- Add and assign Win32 apps: https://learn.microsoft.com/en-us/intune/app-management/deployment/add-win32
- Troubleshoot Win32 apps: https://learn.microsoft.com/en-us/intune/app-management/deployment/troubleshoot-win32
- Microsoft 365 Apps with Intune: https://learn.microsoft.com/en-us/intune/app-management/deployment/add-microsoft-365-windows
- Office Deployment Tool: https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool
- Microsoft 365 Apps admin center: https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview
- Cloud Policy service: https://learn.microsoft.com/en-us/microsoft-365-apps/admin-center/overview-cloud-policy
- Apple volume-purchased apps: https://learn.microsoft.com/en-us/intune/app-management/deployment/manage-vpp-apple
- Managed Google Play apps: https://learn.microsoft.com/en-us/intune/app-management/deployment/add-managed-google-play
- Quiet Time policies: https://learn.microsoft.com/en-us/intune/app-management/protection/configure-quiet-time
- Monitor app assignments: https://learn.microsoft.com/en-us/intune/app-management/monitor-assignments
- Troubleshoot app installation: https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-management/troubleshoot-app-install
- App protection overview: https://learn.microsoft.com/en-us/intune/app-management/protection/overview
- Create app protection policies: https://learn.microsoft.com/en-us/intune/app-management/protection/create-policy
- App-based Conditional Access: https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/app-based-policies
- Migrate from approved client app: https://learn.microsoft.com/en-us/entra/identity/conditional-access/migrate-approved-client-app
- App configuration policies: https://learn.microsoft.com/en-us/intune/app-management/configuration/overview
