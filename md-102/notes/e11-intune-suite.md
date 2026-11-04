# Episode 11 — Intune Suite add-ons: EPM, Remote Help, Cloud PKI, Tunnel for MAM

Video: *Intune Suite Add-ons Explained: EPM, Remote Help, Cloud PKI, Tunnel for MAM* · Exam area: Manage and maintain devices

## Pinecone scenario

The label tool from episode 10 is on every shop laptop, but its printer driver needs admin rights, so the shop
managers want local admin. Endpoint Privilege Management lets them stay standard users and still elevate that
one file. Five more add-ons each solve one more Pinecone problem.

## Key steps

- [ ] Licensing beyond core Intune: Intune Plan 2, the Microsoft Intune Suite, or select Microsoft 365 bundles.
      Try or buy each add-on under **Tenant administration › Intune add-ons**.
- [ ] EPM: **Endpoint security › Endpoint Privilege Management**:
  - [ ] **Windows elevation settings policy**: turns EPM on, installs the EPM client, reporting level, default
        elevation response (deny, or require support approval).
  - [ ] **Windows elevation rules policy**: identify the file (name, path, file hash, certificate) + elevation
        type. Pinecone: printer driver = user confirmed with business justification; everything else = support
        approval.
  - [ ] Optional: elevation system settings policy (standard users change selected network settings).
  - [ ] Monitor on the **Reports** tab (elevation report; by application, publisher, user); create a rule from a
        report entry. Data is processed once every 24 hours.
- [ ] Enterprise App Catalog: **Apps › All apps › Create › Windows › Enterprise App Catalog app** › search › pick
      language, architecture, version › Intune prefills commands, requirements, detection › Required assignment
      with **auto-update** (otherwise update with supersedence).
- [ ] Remote Help: **Tenant administration › Remote Help › Settings** (off by default) › deploy the app (Win32 or
      catalog) › **Devices › All devices › device › New remote assistance session**. Permissions come from Intune
      roles.
- [ ] Cloud PKI: **Tenant administration › Cloud PKI** › root CA › issuing CA (or bring your own CA and anchor a
      cloud issuing CA to it) › trusted certificate profiles for root and issuing CA › **SCEP profile** pointing to
      the issuing CA.
- [ ] Tunnel for MAM: Android: assign the same groups three policies: app configuration for Microsoft Defender,
      app configuration for Microsoft Edge, app protection for Edge. iOS: the Tunnel SDK is built into the app.
      Monitor: **Tenant administration › Microsoft Tunnel Gateway › Health status**.
- [ ] Advanced Analytics: **Reports › Analytics › Endpoint analytics › Anomalies** tab; device timeline; battery
      health; resource performance; device query (episode 7); device scopes (scope tags).

## Decisions

| Pinecone problem | Add-on |
|---|---|
| a driver needs admin, users should stay standard | Endpoint Privilege Management |
| apps to package and keep updated | Enterprise App Management (Enterprise App Catalog) |
| a user needs hands-on help | Remote Help |
| Wi-Fi certificates without on-premises servers | Microsoft Cloud PKI |
| personal phones, no enrollment, need on-premises apps | Microsoft Tunnel for MAM |
| crashes nobody has reported yet | Advanced Analytics |

| EPM elevation type | Behavior |
|---|---|
| Automatic | silent, no prompt; sparingly, trusted files only |
| User confirmed (default) | right-click › Run with elevated access › confirm; optional business justification and/or Windows authentication |
| Support approved | user submits a request; an admin approves first |
| Deny | blocks elevation |
| Elevate as current user | runs under the user's account instead of the virtual account; only when virtual account elevation breaks an app |

| On-premises | Add-on |
|---|---|
| local Administrators group via Group Policy | EPM (rights per file, by rule) |
| third-party remote control tool | Remote Help |
| on-premises CA + NDES + certificate connector | Cloud PKI |

## Exam traps

- **The settings policy turns EPM on; the rules policy says what may elevate.** A rules policy alone does nothing.
- **Deny beats allow** for the same file; a rule assigned to a **user beats** one assigned to a device.
- Default response "require user confirmation" lets every unmatched file elevate; Learn recommends deny or support
  approval.
- Managed elevation = handled by EPM; unmanaged = without EPM (for example Run as administrator).
- Catalog app = **Microsoft did the packaging**; normal Win32 app = you wrap it yourself. Changing prefilled
  commands might make the install fail.
- Remote Help: helper and sharer must be in **your tenant**; compliance warning shows once the session starts;
  **Help Desk Operator lacks Windows unattended sign-in** (custom role needed).
- Cloud PKI issues via **SCEP**; the private key is created on the device and **never leaves it**; dashboard shows
  active, expired, revoked certificates; Windows, macOS, iOS, Android.
- BYOD phone + no enrollment + on-premises access = **Tunnel for MAM** (Android client: Microsoft Defender).
- Advanced Analytics builds on Endpoint analytics (episode 12). You need to know which add-on solves which
  problem, not prices.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Advanced capabilities (add-ons): https://learn.microsoft.com/en-us/intune/fundamentals/advanced-capabilities
- EPM overview: https://learn.microsoft.com/en-us/intune/epm/overview
- EPM elevation rules: https://learn.microsoft.com/en-us/intune/epm/create-elevation-rules
- EPM elevation settings: https://learn.microsoft.com/en-us/intune/epm/manage-elevation-settings
- EPM reports: https://learn.microsoft.com/en-us/intune/epm/monitor-reports
- Enterprise App Management: https://learn.microsoft.com/en-us/intune/app-management/deployment/enterprise-app-management
- Add an Enterprise App Catalog app: https://learn.microsoft.com/en-us/intune/app-management/deployment/add-enterprise-catalog-app
- Remote Help: https://learn.microsoft.com/en-us/intune/remote-help/ · https://learn.microsoft.com/en-us/intune/remote-help/deploy · https://learn.microsoft.com/en-us/intune/remote-help/plan · https://learn.microsoft.com/en-us/intune/remote-help/start-session
- Microsoft Cloud PKI: https://learn.microsoft.com/en-us/intune/cloud-pki/ · https://learn.microsoft.com/en-us/intune/cloud-pki/configure-ca
- Microsoft Tunnel for MAM: https://learn.microsoft.com/en-us/intune/device-security/microsoft-tunnel/mam
- Tunnel for MAM on Android: https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-tunnel-mam-android
- Monitor Microsoft Tunnel: https://learn.microsoft.com/en-us/intune/device-security/microsoft-tunnel/monitor
- Advanced Analytics: https://learn.microsoft.com/en-us/intune/advanced-analytics/
- Anomalies report: https://learn.microsoft.com/en-us/intune/advanced-analytics/anomalies
- Device scopes: https://learn.microsoft.com/en-us/intune/advanced-analytics/device-scopes
