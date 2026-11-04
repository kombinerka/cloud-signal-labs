# Practice set 1 explained — Prepare infrastructure, manage and maintain devices

Video: *MD-102 Practice Questions: Enrollment, Autopilot and Device Management* · Covers exam areas 1 and 2

Original questions written against Microsoft's skills outline, not real exam questions. Try each one before you
read the answer. The "Rewatch" line points to the course episode that teaches it (numbered as in the current
course order: 7 = remote actions, 11 = Intune Suite add-ons). Notes for every episode are in [`../notes/`](../notes/).

Answer key: 1 B · 2 C · 3 A · 4 D · 5 B · 6 C · 7 A · 8 D · 9 B · 10 C · 11 A · 12 D · 13 B · 14 C · 15 A

---

## Question 1 — Device identity

Pinecone's designers want to read work email on their own Windows laptops. They sign in to Windows with a
personal Microsoft account. Which device identity fits?

- A. Microsoft Entra joined
- B. Microsoft Entra registered
- C. Microsoft Entra hybrid joined
- D. No device identity at all

**Answer: B. Microsoft Entra registered.** Registration is built for bring your own device: the user keeps a
personal sign-in and adds a work account.

- A is wrong: Entra join is for organization-owned devices and needs a work account to sign in to Windows; the
  designers sign in with a personal Microsoft account.
- C is wrong: hybrid join means the device is joined to the on-premises Active Directory domain. Personal laptops
  aren't.
- D is wrong: device-based Conditional Access and Intune management need a device identity; a personal device
  always ends up registered.

Rewatch: [episode 1](../notes/e01-device-identity.md)

## Question 2 — Device groups

You need a device group that automatically holds every Windows Autopilot device. Which dynamic membership rule
do you use?

- A. `device.deviceOSType -eq "Windows"`
- B. `device.deviceOwnership -eq "Company"`
- C. `device.devicePhysicalIds -any _ -startsWith "[ZTDId]"`
- D. `device.displayName -startsWith "PC"`

**Answer: C.** Only devices registered for Autopilot carry a ZTDId in their physical IDs, so the rule catches
exactly those, even before setup starts.

- A is wrong: it checks the operating system, not Autopilot registration, and would also pull in every Windows PC
  that was never registered, like Pinecone's old office PCs.
- B is wrong: it catches company-owned devices of every kind, registered for Autopilot or not.
- D is wrong: a name prefix is set (if at all) during setup and says nothing about Autopilot registration; an
  unregistered PC can have the same prefix.

Rewatch: [episode 1](../notes/e01-device-identity.md) · rules: [`commands/e01-dynamic-device-group-rules.txt`](../commands/e01-dynamic-device-group-rules.txt)

## Question 3 — Enrollment

Pinecone's new Windows laptops join Microsoft Entra ID during setup, but they never show up in Intune. What is
the most likely fix?

- A. Set the MDM user scope to Some or All
- B. Create an Android enrollment profile
- C. Assign a compliance policy
- D. Import the ADMX files

**Answer: A.** With the MDM user scope at None, automatic enrollment is off and users must enroll by hand. With
Some or All, devices of users in scope enroll in Intune when they join or register.

- B is wrong: Android enrollment profiles don't affect Windows laptops.
- C is wrong: a compliance policy only reaches devices that are already enrolled; it can't bring an unenrolled
  laptop into Intune.
- D is wrong: ADMX import adds third-party settings to configuration profiles, which also only reach enrolled
  devices.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 4 — Enrollment

Pinecone's sales team gets company-owned Android phones. Staff may also use them for personal things. Which
Android Enterprise enrollment fits?

- A. Fully managed
- B. Dedicated devices
- C. Personally-owned work profile
- D. Corporate-owned with a work profile

**Answer: D. Corporate-owned with a work profile.** It's for company devices with one user that also allow
personal use.

- A is wrong: fully managed is work only; there's no separate work profile, so no personal side for staff's own
  apps and data.
- B is wrong: dedicated devices are kiosk-style devices with no assigned user.
- C is wrong: the personally-owned work profile is for bring your own device; these phones belong to Pinecone.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 5 — Enrollment

Pinecone buys its iPhones through Apple Business Manager. They must enroll over the air, be supervised, and never
need a technician. What do you set up?

- A. Personal enrollment with the Company Portal
- B. Automated device enrollment: a token and an enrollment policy
- C. An app protection policy
- D. Google zero-touch enrollment

**Answer: B.** Automated device enrollment (ADE) is built for corporate devices bought through Apple Business
Manager. The token links that account to Intune, enrollment starts by itself in Setup Assistant, and the devices
are supervised by default.

- A is wrong: Company Portal enrollment is started by the user on each device, and it doesn't make the iPhones
  supervised.
- C is wrong: app protection protects data inside apps; it doesn't enroll the device.
- D is wrong: Google zero-touch is for Android devices, not iPhones.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 6 — Roles and scope tags

The Amsterdam help desk has the Help Desk Operator role. They should only see Amsterdam's devices and policies,
not the rest of Pinecone. What do you add?

- A. A custom role with fewer permissions
- B. Multi-admin approval
- C. A scope tag on the role assignment and on Amsterdam's objects
- D. An assignment filter

**Answer: C.** Roles decide what an admin can do; scope tags decide which objects they can see.

- A is wrong: a custom role only changes what the help desk can do. A role assignment without a scope tag still
  sees every Pinecone object.
- B is wrong: Multi Admin Approval makes a second admin approve protected changes; it doesn't limit what an admin
  can see.
- D is wrong: assignment filters decide which devices receive a policy or app, not which objects admins see.

Rewatch: [episode 3](../notes/e03-roles-compliance.md)

## Question 7 — Compliance

Pinecone wants to block email on any laptop that isn't encrypted with BitLocker. Which combination works?

- A. A compliance policy that requires BitLocker, plus Conditional Access that requires a compliant device
- B. A configuration profile that turns on BitLocker, and nothing else
- C. An enrollment restriction that blocks personal devices
- D. A security baseline for all users

**Answer: A.** The compliance policy checks the device and sets its status; Conditional Access uses that status
to grant or block access. Intune decides compliant or not, Conditional Access decides access.

- B is wrong: a configuration profile turns BitLocker on but sets no compliance status, so Conditional Access has
  nothing to block on.
- C is wrong: enrollment restrictions decide who may enroll which device; they don't check encryption or control
  access to email.
- D is wrong: a baseline is a group of recommended settings that it sets on devices; like a configuration profile,
  it doesn't block access.

Rewatch: [episode 3](../notes/e03-roles-compliance.md)

## Question 8 — Windows Autopilot

Pinecone's shop kiosks have no assigned user. They should set themselves up over Ethernet, with nobody typing
anything. Which Autopilot mode fits?

- A. User-driven
- B. Pre-provisioning
- C. Existing devices
- D. Self-deploying

**Answer: D. Self-deploying.** It's made for kiosks, digital signage and shared devices; over Ethernet it needs
no user interaction, and the TPM 2.0 authenticates the device.

- A is wrong: user-driven needs a person to sign in with their own credentials.
- B is wrong: pre-provisioning needs a technician first, and it ends with a user signing in. The kiosks have
  neither.
- C is wrong: existing devices mode is for devices that already run Windows; it isn't the no-user, no-typing
  kiosk mode the episode teaches.

Rewatch: [episode 4](../notes/e04-autopilot.md)

## Question 9 — Windows Autopilot

New head office laptops should arrive with most apps already installed, so staff can work minutes after they sign
in. Which Autopilot mode fits?

- A. Self-deploying
- B. Pre-provisioning
- C. Autopilot reset
- D. User-driven, without an Enrollment Status Page

**Answer: B. Pre-provisioning.** It splits setup in two: IT or a partner runs the technician flow first (device
policies and device-context apps), and the user only finishes the rest.

- A is wrong: self-deploying is for devices with no assigned user; head office laptops belong to staff, who sign
  in themselves.
- C is wrong: Autopilot reset returns an existing device to a business-ready state; it doesn't pre-install apps
  before shipping.
- D is wrong: plain user-driven installs everything after the user signs in, so nothing is installed in advance;
  dropping the ESP only lets the user in before setup finishes.

Rewatch: [episode 4](../notes/e04-autopilot.md)

## Question 10 — Windows Autopilot

Pinecone buys some Windows 11 laptops from a local shop that can't register them for Windows Autopilot. You still
want Intune to set them up when the user signs in. What do you use?

- A. An Autopilot deployment profile
- B. Self-deploying mode
- C. Windows Autopilot device preparation
- D. Pre-provisioning

**Answer: C. Windows Autopilot device preparation.** It doesn't need device registration. You create a device
preparation policy and a device security group owned by the Intune Provisioning Client.

- A is wrong: a deployment profile only applies to devices registered with their hardware hash.
- B is wrong: self-deploying is a classic Autopilot mode, so it also needs registration (and it's for devices
  without a user).
- D is wrong: pre-provisioning is a classic Autopilot mode too, and needs registered devices.

Rewatch: [episode 4](../notes/e04-autopilot.md) and [episode 6](../notes/e06-configuration-profiles.md) (enrollment time grouping)

## Question 11 — Windows Autopilot

New laptops reach the desktop before the VPN client and security policies are installed, and users call the help
desk. What stops this?

- A. An Enrollment Status Page that blocks device use until all apps and profiles are installed
- B. A shorter device name template
- C. A feature update policy
- D. A dynamic device group

**Answer: A.** The ESP shows setup progress; with blocking set to Yes, users can't leave it until Intune has
finished.

- B is wrong: the name template only names the device.
- C is wrong: a feature update policy only picks the Windows version; it can't hold users at setup until apps
  install.
- D is wrong: a group decides who gets the apps and policies, not whether the user waits for them.

Rewatch: [episode 4](../notes/e04-autopilot.md)

## Question 12 — Windows 365

Pinecone's Cloud PCs must be hybrid joined, with direct access to file servers in the head office. Which network
option do you need?

- A. The Microsoft-hosted network
- B. Microsoft Tunnel
- C. A VPN configuration profile
- D. An Azure network connection

**Answer: D. An Azure network connection.** Hybrid join requires an Azure network connection in your own Azure
subscription; the Microsoft-hosted network supports Microsoft Entra join only.

- A is wrong: Microsoft manages the hosted network, it doesn't work with hybrid join, and it has no direct path
  into Pinecone's own network.
- B is wrong: Microsoft Tunnel is a VPN gateway for mobile devices (episode 11), not a Cloud PC network option.
- C is wrong: a VPN profile configures a device after it exists; the provisioning policy's network option is what
  makes hybrid join possible.

Rewatch: [episode 5](../notes/e05-windows-365.md)

## Question 13 — Configuration profiles

A Wi-Fi profile is assigned to the Sales users group. It should only reach company-owned devices, not staff's
personal ones. What's the simplest way?

- A. Create a separate group for every device
- B. Add an assignment filter on ownership, in include mode
- C. Add a scope tag
- D. Turn it into a compliance policy

**Answer: B.** Filters narrow a group assignment by device properties like ownership, manufacturer or OS version,
and they're evaluated at check-in.

- A is wrong: it works in theory but is the opposite of simple; filters exist so you don't need many small groups.
- C is wrong: scope tags only control which admins can see the profile; they don't change which devices receive it.
- D is wrong: a compliance policy checks devices; it can't deliver Wi-Fi settings.

Rewatch: [episode 6](../notes/e06-configuration-profiles.md) · rules: [`commands/e06-assignment-filter-rules.txt`](../commands/e06-assignment-filter-rules.txt)

## Question 14 — Intune Suite

Pinecone's engineers work as standard users, but they need to run one approved tool with admin rights. You don't
want to make them local admins. What do you use?

- A. Windows LAPS
- B. Remote Help
- C. Endpoint Privilege Management, with an elevation rule for that file
- D. A local group policy that adds them to Administrators

**Answer: C.** An elevation settings policy turns EPM on, and the elevation rule names the file and how it may
elevate. The engineers stay standard users.

- A is wrong: Windows LAPS manages the built-in local administrator password; it doesn't let a standard user
  elevate one tool.
- B is wrong: Remote Help lets a helper view or control the screen; it doesn't give the engineer elevation for a
  file.
- D is wrong: that makes the engineers full local admins for every app, all the time, not just for the one
  approved tool.

Rewatch: [episode 11](../notes/e11-intune-suite.md)

## Question 15 — Remote actions

A designer is leaving Pinecone. Her personal iPhone is enrolled in Intune. You must remove company data and leave
her photos alone. Which remote action?

- A. Retire
- B. Wipe
- C. Fresh Start
- D. Autopilot reset

**Answer: A. Retire.** It removes company data and settings and leaves personal data intact.

- B is wrong: wipe resets the whole iPhone to factory settings, so her personal photos would be deleted too.
- C is wrong: Fresh Start is for Windows only.
- D is wrong: Autopilot reset is a Windows action as well.

Rewatch: [episode 7](../notes/e07-remote-actions.md)

---

Twelve or more right: these two areas are in good shape. Fewer: rewatch episodes 1 to 7, and episode 11 for
Endpoint Privilege Management. Microsoft also has a free official practice assessment for MD-102, linked from the
[Endpoint Administrator Associate certification page](https://learn.microsoft.com/en-us/credentials/certifications/modern-desktop/).
