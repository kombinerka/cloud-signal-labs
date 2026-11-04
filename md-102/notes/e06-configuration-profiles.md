# Episode 6 — Intune configuration profiles

Video: *Intune Configuration Profiles: Settings Catalog, Group Policy Migration and Filters* · Exam area: Manage and maintain devices

## Pinecone scenario

Pinecone has years of settings in Group Policy, but its new laptops and Cloud PCs will never talk to a domain
controller. Those settings move into Intune configuration profiles, for Windows, Android, Apple and specialty
devices, targeted with filters and enrollment time grouping.

## Key steps

- [ ] New profile: **Devices › Manage devices › Configuration › Create › New policy** › platform › profile type
      (settings catalog or templates) › basics › configuration settings › scope tags › assignments › review and
      create. Windows: optional applicability rules (OS edition, OS version).
- [ ] Not built in? A **custom** profile (for example an OMA-URI on Windows).
- [ ] Group Policy analytics: export each GPO as an XML report from the **Group Policy Management console** ›
      **Devices › Manage devices › Group Policy analytics › Import** › check the **MDM support** percentage and
      the CSP mapping per setting › select the GPO › **Migrate** › pick settings › review values › assign. Result:
      a settings catalog policy.
- [ ] Third-party ADMX (preview): **Configuration › Import ADMX** tab › upload the ADMX + its English ADML
      (import parent templates first) › create a profile, type **Templates › Imported Administrative templates**.
- [ ] Android Enterprise: device restrictions template, grouped by fully managed / dedicated / corporate-owned
      work profile; kiosk mode (single or multi-app) on dedicated devices.
- [ ] iOS/iPadOS: check **supervised** settings (for example Block App Store); supervision comes from ADE or
      Apple Configurator. Device features: AirPrint, home screen layout, lock screen message. macOS: settings
      catalog, device restrictions, device features (login window).
- [ ] Specialty: Teams Rooms in their own dynamic device group, **excluded** from general configuration and
      compliance policies; HoloLens 2 with Windows profiles (VPN targets the device); Zebra with **OEMConfig**
      (app from Managed Google Play + OEMConfig profile).
- [ ] Assignment filter: **Tenant administration › Assignment filters** › managed devices or managed apps › rule
      ([`commands/e06-assignment-filter-rules.txt`](../commands/e06-assignment-filter-rules.txt)) › use it in
      include or exclude mode on an assignment. Pinecone: kiosk profile to All devices with a filter on device
      names starting with KIOSK.
- [ ] Enrollment time grouping: add a **static** Entra security group, owned by the **Intune Provisioning
      Client** service principal, to the enrollment policy.

## Decisions

| Settings catalog | Templates |
|---|---|
| every setting in one place; search and filter; "like Group Policy, but cloud native" | settings grouped for one feature: Wi-Fi, VPN, email, device restrictions, kiosk |
| Windows, macOS, iOS/iPadOS, Android Enterprise, AOSP | per platform |

| Targeting | Use when |
|---|---|
| Group | scope; also needed for Conditional Access and licensing |
| Assignment filter | Intune-only targeting by device property (OS version, manufacturer, model, ownership); evaluated at check-in, no wait for group membership |
| Enrollment time grouping | profiles must arrive during enrollment (Autopilot device preparation, Apple ADE, Android Enterprise corporate-owned); new enrollments only, one group per policy |

"Groups define scope, filters define targeting."

| Collision | Result |
|---|---|
| Two configuration profiles, different values | conflict shown in Intune; resolve manually |
| Compliance policy vs configuration profile | compliance wins |
| Two compliance policies | most restrictive applies |
| Settings catalog setting in user and device scope | user scope wins |

## Exam traps

- A configuration profile **sets**, a compliance policy **checks** (episode 3).
- Settings catalog tags: a **user** setting writes to the current user's registry, a **device** setting to the
  local machine; a user setting assigned to a device applies to **every user** on it.
- Group Policy migration is **best effort**: review instead of migrating everything. **AppLocker and firewall
  rules don't migrate**; they belong in Endpoint security.
- Don't import the built-in Windows ADMX files; use the settings catalog. ADMX import is preview; English ADML
  only.
- Many iOS restrictions need a **supervised** device. Check the enrollment type next to each Apple setting.
- Zebra on Android Enterprise = **OEMConfig**; the older MX profile is for Android device administrator
  (deprecated).
- Teams Rooms: password policies can stop the room account signing in automatically.
- Without enrollment time grouping a new device can take up to **8 hours** to get all apps and policies; devices
  check in about every 8 hours, or immediately on sync.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Create device configuration profiles: https://learn.microsoft.com/en-us/intune/device-configuration/create-device-profile
- Device features and settings overview: https://learn.microsoft.com/en-us/intune/device-configuration/overview
- Settings catalog: https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/
- Group Policy analytics: https://learn.microsoft.com/en-us/intune/device-configuration/import-group-policy-analytics
- Migrate imported Group Policy: https://learn.microsoft.com/en-us/intune/device-configuration/migrate-group-policy
- Import custom ADMX templates: https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/import-custom-admx-templates
- Android Enterprise device restrictions: https://learn.microsoft.com/en-us/intune/device-configuration/templates/ref-device-restrictions-android-enterprise
- Apple device restrictions: https://learn.microsoft.com/en-us/intune/device-configuration/templates/ref-device-restrictions-apple
- Apple device features: https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-device-features-apple
- Teams Rooms with Autopilot: https://learn.microsoft.com/en-us/microsoftteams/rooms/autopilot-autologin
- Teams Rooms compliance and CA: https://learn.microsoft.com/en-us/microsoftteams/rooms/supported-ca-and-compliance-policies?tabs=mtr-a
- Windows Holographic with Intune: https://learn.microsoft.com/en-us/intune/solutions/windows-holographic
- OEMConfig on Android Enterprise: https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-oemconfig-android
- Zebra MX: https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-zebra-mx-android
- Assignment filters: https://learn.microsoft.com/en-us/intune/fundamentals/filters/overview
- Filter properties and operators: https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/filters-device-properties
- Choose the right targeting method: https://learn.microsoft.com/en-us/intune/fundamentals/choose-targeting-method
- Enrollment time grouping: https://learn.microsoft.com/en-us/intune/device-enrollment/setup-time-grouping
- Troubleshoot policies and profiles: https://learn.microsoft.com/en-us/intune/device-configuration/troubleshoot-device-profiles
