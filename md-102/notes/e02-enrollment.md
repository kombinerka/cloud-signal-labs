# Episode 2 — Intune enrollment: Windows, iPhone, Mac and Android

Video: *Intune Enrollment Explained: Windows, iPhone, Mac and Android Devices* · Exam area: Prepare infrastructure for devices

## Pinecone scenario

Pinecone's new laptops are all Entra joined, yet Intune shows none of them as managed. Joining gave them an
identity; nobody turned on enrollment. This episode gets every device type into Intune: Windows, personal and
company Apple devices, and Android.

## Key steps

Windows
- [ ] **Intune admin center › Devices › Device onboarding › Enrollment › Windows tab › Automatic Enrollment**
      (needs Microsoft Entra ID P1 or P2).
- [ ] Set **MDM user scope** to **Some** (picked groups) or **All**. Leave **WIP user scope** at **None**.
      Select **Save**. From then on a company laptop that joins Entra ID enrolls by itself and shows up under
      **Devices › Windows** as corporate-owned.
- [ ] Require multifactor authentication when devices register (Microsoft's recommendation).
- [ ] Personal Windows PC: **Settings › Accounts › Access work or school**, or the Company Portal app.
- [ ] Enrollment restrictions: **device platform** restrictions (platforms, min/max OS version, Android
      manufacturers, block personally owned) and **device limit** restrictions (1 to 15 per user). Edit the default
      policy or assign stricter/looser ones to groups.

Apple
- [ ] **Devices › Device onboarding › Enrollment › Apple tab › Apple MDM Push Certificate**. Valid 365 days;
      renew every year **with the same Apple account**; use a company mailbox more than one person can read.
- [ ] Personal iPhone: device enrollment with Company Portal, web-based device enrollment (Safari), or
      **account-driven user enrollment** (user adds a work account under **Settings › VPN & Device Management**).
- [ ] Personal Mac: Company Portal installer, sign in, **approve the management profile**.
- [ ] Company iPhones/Macs: **automated device enrollment (ADE)** through Apple Business Manager (Learn now says
      "Apple Business") or Apple School Manager: upload the ADE token (.p7m) to create the trust, sync device
      records, create an enrollment policy (user affinity, authentication method, Setup Assistant screens),
      assign it. Setup Assistant with modern authentication is recommended. On the enrollment program token,
      select **Set Default Policy** so every synced device gets it (a synced device with no policy fails to
      enroll).

Android
- [ ] Connect the tenant to **Managed Google Play** (needed for every Android Enterprise option).
- [ ] Pick the profile per phone (table below).
- [ ] Corporate methods: QR code (recommended for most scenarios), NFC, token, **Google zero-touch**,
      **Samsung Knox Mobile Enrollment**. Zero-touch: pick Microsoft Intune in the zero-touch portal and paste the
      JSON with the enrollment token (or link the zero-touch account inside Intune). Knox: create a profile in the
      Knox Admin Portal, choose Intune, add the enrollment token.

## Decisions

| MDM user scope | Effect |
|---|---|
| None | automatic enrollment off; users enroll by hand |
| Some | only the groups you pick enroll when they join or register |
| All | everyone enrolls when they join or register with Entra ID |

| Apple device | Method |
|---|---|
| Personal iPhone, full device, Intune sees serial and IMEI | device enrollment with Company Portal, or web-based device enrollment |
| Personal iPhone, privacy first (separate volume, no serial/IMEI) | account-driven user enrollment |
| Personal Mac | Company Portal + user approves the management profile |
| Corporate, zero touch, supervised by default | automated device enrollment (Apple Business Manager) |

| Android owner / use | Android Enterprise profile |
|---|---|
| Personal phone (BYOD) | personally owned work profile |
| Company phone, one user, work only | fully managed |
| Company phone, one user, personal use allowed | corporate-owned work profile |
| No user (kiosk) | dedicated device |

| Enrollment error | Usual cause |
|---|---|
| Device cap reached | user hit the device limit: remove stale devices or raise the limit |
| "Your IT admin hasn't given you access" | missing Intune license |
| Profile installation failed | missing license, another management profile, or another MDM already on the device |
| Blocked by restriction | check which platform restriction is assigned to the user's group |

Co-management (bridge from Configuration Manager): keep the ConfigMgr client, hybrid join existing clients, enroll
them in Intune, then switch workloads (compliance, Windows Update policies, device configuration...) one at a
time. For each switched workload, Intune becomes the authority.

## Exam traps

- Joined is not enrolled: **identity first, enrollment second**.
- If a user is in both MDM and WIP scopes: a company device enrolls, a personal device does not.
- Enrollment restrictions are **not a security feature** (best-effort barrier for honest users) and apply only to
  **user-driven** enrollment; Autopilot self-deploying always gets the default policy.
- Blocking personal Windows devices does **not** block Autopilot, a provisioning package, or a device enrollment
  manager.
- iPhones and Macs count as **personal by default**; corporate when the serial number is registered or they enroll
  through ADE.
- Two limits: Intune limits **enrollments**, Entra's maximum number of devices limits **joins and
  registrations**. The stricter one wins.
- Renew the Apple push certificate with the **same Apple account**, or you re-enroll everything.
- User enrollment with the Company Portal is deprecated for new devices; **Android device administrator is
  deprecated** (don't enroll new devices with it).
- Don't restart an Android phone in the middle of enrollment.
- Troubleshooting basics: platform set up? user licensed? exact error, platform, method? device clock correct?
  Self-help diagnostics are in the Microsoft 365 admin center.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Enable MDM automatic enrollment for Windows: https://learn.microsoft.com/en-us/intune/device-enrollment/windows/enable-automatic-mdm
- What is co-management?: https://learn.microsoft.com/en-us/intune/configmgr/comanage/overview
- Enrollment restrictions: https://learn.microsoft.com/en-us/intune/device-enrollment/restrictions
- Intune and Microsoft Entra device limits: https://learn.microsoft.com/en-us/intune/device-enrollment/limits-intune-entra
- Apple MDM push certificate: https://learn.microsoft.com/en-us/intune/device-enrollment/apple/create-mdm-push-certificate
- iOS/iPadOS enrollment guide: https://learn.microsoft.com/en-us/intune/device-enrollment/apple/guide-ios-ipados
- Apple User Enrollment: https://learn.microsoft.com/en-us/intune/device-enrollment/apple/user-enrollment-methods-ios
- macOS enrollment guide: https://learn.microsoft.com/en-us/intune/device-enrollment/apple/guide-macos
- Apple Automated Device Enrollment: https://learn.microsoft.com/en-us/intune/device-enrollment/apple/overview-automated-enrollment-apple
- Set up automated device enrollment for iOS/iPadOS (Set Default Policy): https://learn.microsoft.com/en-us/intune/device-enrollment/apple/setup-automated-ios
- Connect Intune to Managed Google Play: https://learn.microsoft.com/en-us/intune/device-enrollment/android/connect-managed-google-play
- Android enrollment guide: https://learn.microsoft.com/en-us/intune/device-enrollment/android/guide
- Android corporate enrollment methods: https://learn.microsoft.com/en-us/intune/device-enrollment/android/ref-corporate-methods
- Samsung Knox Mobile Enrollment: https://learn.microsoft.com/en-us/intune/device-enrollment/android/setup-samsung-knox-mobile
- Troubleshoot device enrollment: https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-enrollment/troubleshoot-device-enrollment-in-intune
