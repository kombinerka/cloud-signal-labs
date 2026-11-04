# Episode 3 — Intune roles, scope tags and compliance policies

Video: *Intune Roles, Scope Tags and Compliance Policies Explained* · Exam area: Prepare infrastructure for devices

## Pinecone scenario

A help desk admin meant to restart one laptop in Amsterdam and wiped a laptop in the Zurich shop instead. He had
rights on every device and nobody had to approve it. Three questions: who may do what, and where? Is the device
healthy enough to get in? Who is admin on the laptop itself?

## Key steps

- [ ] Roles: **Tenant administration › Roles**. Use a built-in role, or a custom role with only the permissions the
      job needs (least privilege).
- [ ] Scope tags: **Tenant administration › Roles › Scope tags** › create "Zurich", tag the Zurich devices,
      policies and apps.
- [ ] Role assignment: role **Help Desk Operator** › Members = Zurich help desk group › Scope groups = Zurich
      devices › Scope tags = Zurich.
- [ ] Multi Admin Approval: **Tenant administration › Multi Admin Approval** › access policy for one resource type
      (Pinecone: **Device actions** type = wipe, retire, delete) + an approver group. A second admin approves the
      new access policy, then its creator selects **Complete**.
- [ ] Compliance policy: **Devices › Compliance › Create policy** (one per platform). Pinecone's Windows policy:
      **Encryption of data storage on a device = Require** › Assignments: the laptop group › actions for
      noncompliance.
- [ ] Tenant-wide compliance settings: "Mark devices with no compliance policy assigned as" › **Not compliant**
      when you use Conditional Access; compliance status validity period (default 30 days).
- [ ] Conditional Access: **Endpoint security › Conditional Access › Create new policy** › users › cloud apps ›
      Grant **Require device to be marked as compliant** › exclude your own admin account › switch from
      Report-only to **On**. Needs Microsoft Entra ID P1 or P2.
- [ ] Windows Hello for Business at enrollment (tenant-wide): **Devices › Enrollment › Windows tab › Windows Hello
      for Business** (Enabled / Disabled / Not configured; TPM, PIN length, biometrics). After enrollment, for
      groups: **Endpoint security › Account protection** or the settings catalog.
- [ ] Windows LAPS: Entra admin center **Devices › Device settings › Enable Local Administrator Password Solution
      (LAPS) = Yes** (needed for Entra joined devices), then **Endpoint security › Account protection › Create
      policy › Local admin password solution (Windows LAPS)**: backup directory, password age in days. Assign to
      device groups. Read it on the device page › **Local admin password**; rotate as a device action.
- [ ] Local admins: **Endpoint security › Account protection › Local user group membership** profile.

## Decisions

| Part of a role assignment | Answers |
|---|---|
| Role | **what** an admin can do |
| Scope tag | **which objects** an admin can see |
| Scope group | **who** (users/devices) an admin can manage |
| Members | which admin group gets the permissions |

| Built-in role | Does |
|---|---|
| Help Desk Operator | remote tasks on users and devices |
| Policy and Profile Manager | compliance policies and configuration profiles |
| Read Only Operator | views, changes nothing |
| Intune Role Administrator | custom roles and role assignments |
| Cloud PC Administrator / Cloud PC Reader | Windows 365 |

| Configuration Manager | Intune |
|---|---|
| security role | Intune role |
| security scope | scope tag |
| collection | scope group (Entra group) |

| Configuration profile | Compliance policy |
|---|---|
| **sets** things on the device | **checks** the device, reports compliant / noncompliant |

| Local user group membership action | Effect |
|---|---|
| Add (Update) | adds members, leaves everyone else |
| Remove (Update) | removes only the members you name |
| Add (Replace) | replaces the whole membership (like Restricted Groups); Replace wins over Update |

## Exam traps

- Role vs scope tag: the classic trap. A role assignment **without a scope tag sees all objects**.
- Untagged objects get the **Default** scope tag; a new object gets all scope tags of the admin who created it.
- Built-in roles can't be edited. Global Administrator and Intune Administrator have full Intune access: not for
  daily work; use Intune roles and PIM.
- Multi Admin Approval: requester writes a justification › approver approves or rejects › **requester selects
  Complete**. You can't approve your own request; approved requests expire after **3 days**.
- Compliance on its own blocks nothing: **Intune decides compliant or not, Conditional Access decides access.**
- Default noncompliance action marks the device noncompliant **immediately**; delay it for a grace period. Remote
  lock only for Android, iPhone, iPad and Mac.
- Default for devices with no compliance policy is **Compliant**: change it with Conditional Access.
- LAPS backs up to Entra ID **or** Active Directory, not both. The password is only viewable in Intune with Entra
  backup; every retrieval is audited; rotation is one device at a time. Without an account name, LAPS manages the
  built-in administrator.
- Windows Hello: **tenant-wide at enrollment** vs **group-targeted after enrollment**.
- Local group membership: picking Entra users/groups works on Entra joined devices; manual entry also works on
  hybrid joined devices.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- RBAC with Microsoft Intune: https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/overview
- RBAC and scope tags: https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/scope-tags
- Windows 365 role-based access: https://learn.microsoft.com/en-us/windows-365/enterprise/role-based-access
- Multi Admin Approval: https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/multi-admin-approval
- Configuration Manager role-based administration: https://learn.microsoft.com/en-us/intune/configmgr/core/understand/fundamentals-of-role-based-administration
- Device compliance overview: https://learn.microsoft.com/en-us/intune/device-security/compliance/overview
- Create a compliance policy: https://learn.microsoft.com/en-us/intune/device-security/compliance/create-policy
- Windows compliance settings (Encryption of data storage on a device): https://learn.microsoft.com/en-us/intune/device-security/compliance/ref-windows-settings
- Actions for noncompliance: https://learn.microsoft.com/en-us/intune/device-security/compliance/configure-noncompliance-actions
- Device-based Conditional Access with Intune: https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/device-based-policies
- Tenant-wide Windows Hello for Business policy: https://learn.microsoft.com/en-us/intune/device-security/identity-protection/configure-tenant-wide-policy
- Windows Hello for groups of devices: https://learn.microsoft.com/en-us/intune/device-security/identity-protection/deploy-group-policy
- Windows LAPS with Intune: https://learn.microsoft.com/en-us/intune/device-security/laps/overview · https://learn.microsoft.com/en-us/intune/device-security/laps/deploy-policy
- Windows LAPS with Microsoft Entra ID: https://learn.microsoft.com/en-us/entra/identity/devices/howto-manage-local-admin-passwords
- Account protection policies: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/account-protection
