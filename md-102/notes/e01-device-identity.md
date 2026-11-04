# Episode 1 — Entra registered vs joined vs hybrid joined

Video: *Entra Registered vs Joined vs Hybrid Joined: Start Here for MD-102* · Exam area: Prepare infrastructure for devices

## Pinecone scenario

One desk, three devices: a new company laptop (the first of 300), an old office PC already in the on-premises
domain, and a manager's personal phone. Each needs a device identity in Microsoft Entra ID, but not the same kind.
Ask two questions: **who owns the device, and how does the user sign in?**

## Key steps

- [ ] Decide the join type per device (table below). New or reset company Windows devices: Entra joined.
- [ ] Check who may join and register: **Microsoft Entra admin center › Devices › Device settings**
      ("Users may join devices to Microsoft Entra ID", "Users may register their devices with Microsoft Entra ID",
      "Maximum number of devices").
- [ ] Join a running Windows device: **Settings › Accounts › Access work or school › Connect**, then choose
      the option to **join this device to Microsoft Entra ID** (Connect alone registers). Other join ways:
      a work account during Windows setup (OOBE), Windows Autopilot, a provisioning package (bulk).
- [ ] Register a personal device: Windows in **Settings**; iPhone/Android through the **Company Portal** or
      **Microsoft Authenticator** app.
- [ ] Hybrid join: Microsoft Entra Connect or Cloud Sync brings the on-premises computer objects to the cloud.
- [ ] Create a dynamic device group: **Intune admin center › Groups › New group** › Group type **Security** ›
      Membership type **Dynamic Device** › **Add dynamic query** › write the rule
      (rules: [`commands/e01-dynamic-device-group-rules.txt`](../commands/e01-dynamic-device-group-rules.txt)) ›
      **Create** › open the group's **Members** page; once processing finishes, the matching devices are listed.

## Decisions

| | Entra registered | Entra joined | Entra hybrid joined |
|---|---|---|---|
| Owner | user (BYOD) or organization; mobile | organization | organization |
| Sign-in to the device | the user's own sign-in (personal Microsoft account, PIN) + a work account added | work account | on-premises AD account |
| Typical device | personal phone, personal PC; **iOS and Android are only registered** | new or reset company Windows device (Microsoft's default) | existing domain-joined PC that can't be reset yet |
| Needs a domain controller | no | no (internet only) | line of sight from time to time; VPN when cached credentials expire |
| Managed by Intune? | not yet: registration is not enrollment | after enrollment (episode 2) | after enrollment (episode 2) |

When hybrid join still makes sense: you still need Group Policy, an existing imaging process, or apps that rely on
Active Directory machine authentication. It is a bridge, not the goal.

| Group type | Members | Use for |
|---|---|---|
| Assigned | added and removed by hand | small, stable sets |
| Dynamic | a rule adds and removes them; no manual members | large fleets that keep changing |

Target **users** when a setting should follow the person (an email profile); target **devices** when it should
apply whoever signs in (a shop kiosk). A dynamic group holds users or devices, never both.

`deviceTrustType` shows the join type: `AzureAD` = joined, `ServerAD` = hybrid joined, `Workplace` = registered.

## Exam traps

- **Registration is not enrollment.** A registered device has an identity, but Intune does not manage it yet.
- You **cannot convert** a hybrid joined device to Entra joined without resetting Windows.
- A personal device always ends up **registered**. Joining = organization owns it + work-account sign-in.
- Intune stores no identities and has **no organizational units**: you target Entra groups.
- An Entra joined laptop checks in with Intune about **every 8 hours**; you can sync it at once.
- For registered phones Microsoft suggests app protection (MAM), with or without device management (episode 10).
- Assignment filters (episode 6) are the Intune-side alternative to many small groups; they evaluate at check-in.
- MD-102 has five skill areas; the pass mark is **700**.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- What is device identity in Microsoft Entra ID?: https://learn.microsoft.com/en-us/entra/identity/devices/overview
- Microsoft Entra registered devices: https://learn.microsoft.com/en-us/entra/identity/devices/concept-device-registration
- Microsoft Entra joined devices: https://learn.microsoft.com/en-us/entra/identity/devices/concept-directory-join
- Windows enrollment guide (join from Settings): https://learn.microsoft.com/en-us/intune/device-enrollment/windows/guide
- Microsoft Entra hybrid joined devices: https://learn.microsoft.com/en-us/entra/identity/devices/concept-hybrid-join
- Join your cloud-native endpoints to Microsoft Entra: https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/entra-join-types
- Plan your Microsoft Entra device deployment: https://learn.microsoft.com/en-us/entra/identity/devices/plan-device-deployment
- Manage devices in the Microsoft Entra admin center: https://learn.microsoft.com/en-us/entra/identity/devices/manage-device-identities
- What is Microsoft Intune?: https://learn.microsoft.com/en-us/intune/fundamentals/what-is-intune
- Intune core concepts (identities): https://learn.microsoft.com/en-us/intune/fundamentals/tenant-administration/identities
- Rules for dynamic membership groups: https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership
- Create device groups for Windows Autopilot: https://learn.microsoft.com/en-us/autopilot/enrollment-autopilot
- Assignment filters: https://learn.microsoft.com/en-us/intune/fundamentals/filters
- Common questions with policies and profiles (8-hour check-in): https://learn.microsoft.com/en-us/intune/device-configuration/troubleshoot-device-profiles
