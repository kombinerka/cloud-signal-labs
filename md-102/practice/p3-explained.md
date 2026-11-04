# Practice set 3 explained — The full practice exam, all five skill areas

Video: *MD-102 Practice Exam: 40 Questions Across All Five Skill Areas* · Covers exam areas 1 to 5

Original questions written against Microsoft's skills outline, not real exam questions. Try each one before you
read the answer. The split follows the exam weights: 9 on preparing infrastructure, 11 on managing and maintaining
devices, 7 on protecting devices, 7 on apps, 6 on automation, monitoring and reporting. The "Rewatch" line points to
the course episode that teaches it (numbered as in the current course order: 7 = remote actions, 11 = Intune Suite
add-ons). Notes for every episode are in [`../notes/`](../notes/).

Answer key: 1 B · 2 D · 3 A · 4 C · 5 C · 6 A · 7 D · 8 B · 9 A · 10 C · 11 D · 12 B · 13 A · 14 D · 15 C · 16 B · 17 B · 18 A · 19 C · 20 D · 21 D · 22 A · 23 C · 24 B · 25 B · 26 D · 27 A · 28 C · 29 A · 30 D · 31 B · 32 C · 33 D · 34 A · 35 C · 36 B · 37 D · 38 A · 39 B · 40 C

---

## Question 1 — Prepare infrastructure

Pinecone's older office PCs are in the on-premises Active Directory domain. They still need Group Policy, and IT can't reset them yet. Which device identity fits?

- A. Microsoft Entra registered
- B. Microsoft Entra hybrid joined
- C. Microsoft Entra joined
- D. No device identity, only Intune enrollment

**Answer: B. Microsoft Entra hybrid joined.** The PC stays joined to the on-premises domain and is also registered with Entra ID, so Group Policy keeps working.

- A is wrong: registration is for personal and mobile devices where the user keeps a personal sign-in; it doesn't keep the PC in the domain.
- C is wrong: Microsoft recommends Entra join for new and reset devices. A PC that leaves the domain gets no Group Policy.
- D is wrong: device-based Conditional Access and Intune management need a device identity in Microsoft Entra ID.

Rewatch: [episode 1](../notes/e01-device-identity.md)

## Question 2 — Prepare infrastructure

Pinecone blocks personally owned Windows devices with a device platform restriction. A user can't enroll his home PC through the Company Portal, but new laptops still enroll through Windows Autopilot. Why?

- A. The restriction only applies to Macs
- B. Autopilot ignores all enrollment restrictions
- C. The restriction needs a day to take effect
- D. Autopilot counts as an authorized corporate enrollment

**Answer: D. Autopilot counts as an authorized corporate enrollment.** When personal Windows devices are blocked, Intune checks that each enrollment is authorized as corporate. Autopilot is on that list, and so are provisioning packages and the device enrollment manager.

- A is wrong: device platform restrictions cover every platform, Windows included.
- B is wrong: Autopilot isn't exempt from restrictions in general. It passes this one because Intune treats it as corporate.
- C is wrong: nothing about timing explains it; the personal home PC is already being blocked.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 3 — Prepare infrastructure

A Pinecone manager tries to enroll a new phone and gets the error Device cap reached. What fixes it?

- A. Remove her stale devices, or raise the device limit restriction
- B. Renew the Apple MDM push certificate
- C. Assign her a Windows 365 license
- D. Set the MDM user scope to None

**Answer: A. Remove her stale devices, or raise the device limit restriction.** The error means she is trying to enroll more devices than her device limit allows. Remove devices she no longer uses, or raise the limit.

- B is wrong: the Apple MDM push certificate is needed to manage Apple devices; it has nothing to do with a per-user device limit.
- C is wrong: a Windows 365 license is for Cloud PCs, not for enrolling a phone.
- D is wrong: Setting the MDM user scope to None turns automatic Windows enrollment off. It doesn't change anyone's device limit.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 4 — Prepare infrastructure

Pinecone's Apple MDM push certificate expires next month. The admin who created it has left the company. What should you do?

- A. Delete it, and create a new certificate
- B. Renew it with your own Apple account
- C. Renew it with the same Apple account that created it
- D. Nothing. Intune renews it automatically

**Answer: C. Renew it with the same Apple account that created it.** Learn says to renew the certificate with the same Apple account you used to create it. That's why Microsoft suggests a company address that more than one person can read.

- A is wrong: If you delete the certificate, Pinecone's Apple devices must be reset and enrolled again.
- B is wrong: Learn says to renew with the same Apple account that created the certificate, not a different one.
- D is wrong: the certificate is valid for 365 days and you must renew it yourself every year (there's a 30-day grace period after expiry).

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 5 — Prepare infrastructure

Staff want work email on their own iPhones. They don't want Pinecone to see the serial number or the IMEI, and work data must stay separate. Which enrollment fits?

- A. Automated device enrollment
- B. Device enrollment with the Company Portal
- C. Account-driven user enrollment
- D. Apple Configurator

**Answer: C. Account-driven user enrollment.** With user enrollment, Intune doesn't collect the serial number or the IMEI, and work data lives on a separate volume. The user starts it in Settings.

- A is wrong: automated device enrollment is for corporate devices bought through Apple Business Manager, not staff's own iPhones.
- B is wrong: Company Portal device enrollment manages the whole device, and Intune sees its serial number and IMEI.
- D is wrong: Apple Configurator is a corporate, hands-on method, not a privacy-friendly option for personal phones.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 6 — Prepare infrastructure

Pinecone buys Samsung phones through a Samsung-approved reseller. They must enroll in Intune straight out of the box, as fully managed devices. What do you set up?

- A. A Knox Mobile Enrollment profile, with Intune and your enrollment token
- B. Android device administrator enrollment
- C. Apple automated device enrollment
- D. Account-driven user enrollment

**Answer: A. A Knox Mobile Enrollment profile, with Intune and your enrollment token.** Knox Mobile Enrollment enrolls devices as soon as they're turned on. The reseller uploads them to the Knox Admin Portal, and the profile points to Intune.

- B is wrong: Android device administrator is deprecated. Microsoft says not to enroll new devices with it.
- C is wrong: automated device enrollment is for Apple devices.
- D is wrong: account-driven user enrollment is the privacy option for personal Apple devices.

Rewatch: [episode 2](../notes/e02-enrollment.md)

## Question 7 — Prepare infrastructure

Wipes at Pinecone are protected by Multi Admin Approval. Sam requested a wipe, and Lena approved it, but the laptop still isn't wiped. What's missing?

- A. Lena must approve it a second time
- B. A Global Administrator must approve it too
- C. Sam must approve his own request
- D. Sam must select Complete on the approved request

**Answer: D. Sam must select Complete on the approved request.** After approval, the requester selects Complete, and only then does Intune apply the change. A request that isn't completed within three days expires.

- A is wrong: one approval from a different admin is enough; the next step is the requester's.
- B is wrong: multi Admin Approval needs a different admin from the approver group, not specifically a Global Administrator.
- C is wrong: An admin can never approve their own request. A different admin must approve it.

Rewatch: [episode 3](../notes/e03-roles-compliance.md)

## Question 8 — Prepare infrastructure

Pinecone's Conditional Access policy requires a compliant device. New laptops with no compliance policy assigned still get email. Which setting closes this gap?

- A. Compliance status validity period, set to one day
- B. Mark devices with no compliance policy assigned as, set to Not compliant
- C. An enrollment restriction that blocks personal devices
- D. A remote lock action for noncompliance

**Answer: B. Mark devices with no compliance policy assigned as, set to Not compliant.** By default, devices without a compliance policy count as compliant. With Conditional Access, Microsoft says to change this to Not compliant.

- A is wrong: The validity period only catches devices that stop reporting on the policies they received. These laptops have no policy at all.
- C is wrong: enrollment restrictions decide who may enroll; they don't change how devices without a compliance policy are marked.
- D is wrong: remote lock is an action for noncompliance inside a policy; these laptops have no policy at all.

Rewatch: [episode 3](../notes/e03-roles-compliance.md)

## Question 9 — Prepare infrastructure

Pinecone deploys a Windows LAPS policy to its Microsoft Entra joined laptops, with Microsoft Entra ID as the backup directory. What must also be turned on in Microsoft Entra ID?

- A. Enable Local Administrator Password Solution, in device settings
- B. Multi Admin Approval
- C. Microsoft Entra hybrid join
- D. Windows Hello for Business

**Answer: A. Enable Local Administrator Password Solution, in device settings.** For Entra joined devices, LAPS must be enabled in Entra ID, under Devices, Device settings. Hybrid joined devices don't need that switch.

- B is wrong: multi Admin Approval protects admin changes; it has nothing to do with LAPS backup.
- C is wrong: Hybrid join isn't required. Cloud backup works for both Entra joined and hybrid joined devices.
- D is wrong: Windows Hello for Business replaces the user's password with a PIN or biometrics; it doesn't manage the local admin account.

Rewatch: [episode 3](../notes/e03-roles-compliance.md)

## Question 10 — Manage and maintain

Which Autopilot device name template is valid for Pinecone's Amsterdam laptops?

- A. PC_AMS_%RAND:4%
- B. PINECONE-AMSTERDAM-%RAND:4%
- C. PC-AMS-%RAND:4%
- D. %RAND:15%

**Answer: C. PC-AMS-%RAND:4%.** Names must be fifteen characters or less, use letters, numbers and hyphens, and can't be all numbers. This one makes names like PC dash AMS dash zero one four two.

- A is wrong: device names can only contain letters, numbers and hyphens, so underscores aren't allowed.
- B is wrong: pINECONE-AMSTERDAM- alone is 19 characters; names must be 15 characters or less.
- D is wrong: Fifteen random digits fit the length, but a device name can't be all numbers.

Rewatch: [episode 4](../notes/e04-autopilot.md)

## Question 11 — Manage and maintain

Pinecone turned on Enable Windows backup in a settings catalog profile, and users have backups. But new Entra joined laptops, set up with user-driven Autopilot, never show a restore page. What's missing?

- A. Switch Autopilot to self-deploying mode
- B. Hybrid join the laptops
- C. A Windows Hello for Business policy
- D. The tenant-wide restore setting, under Devices, Enrollment

**Answer: D. The tenant-wide restore setting, under Devices, Enrollment.** Backup and restore are two separate switches. Restore is a tenant-wide enrollment setting, and it's off by default.

- A is wrong: Restore doesn't work with self-deploying mode. It needs user-driven Autopilot, which Pinecone already uses.
- B is wrong: restore needs Microsoft Entra join; hybrid join isn't supported for restore.
- C is wrong: Windows Hello for Business configures sign-in, not settings backup and restore.

Rewatch: [episode 4](../notes/e04-autopilot.md)

## Question 12 — Manage and maintain

Twenty new agents have Windows 365 Enterprise licenses, but no Cloud PCs appear. What's missing?

- A. An Autopilot deployment profile
- B. A provisioning policy assigned to a group they're in
- C. A compliance policy
- D. An Azure network connection

**Answer: B. A provisioning policy assigned to a group they're in.** Windows 365 provisions Cloud PCs for licensed users in the groups assigned to a provisioning policy. A license alone isn't enough.

- A is wrong: Cloud PCs aren't set up with an Autopilot deployment profile; the provisioning policy creates and enrolls them.
- C is wrong: a compliance policy checks a device after it exists; it doesn't create Cloud PCs.
- D is wrong: An Azure network connection is only required for hybrid join. The Microsoft-hosted network needs none.

Rewatch: [episode 5](../notes/e05-windows-365.md)

## Question 13 — Manage and maintain

A designer's Cloud PC needs more RAM and CPU. She must keep all her files and apps. Which action do you use?

- A. Resize
- B. Reprovision
- C. Restore
- D. Fresh Start

**Answer: A. Resize.** Resize upgrades RAM, CPU and storage, and it preserves user and disk data. She's disconnected while it runs, so she should save her work first.

- B is wrong: Reprovision deletes the Cloud PC and builds a new one, so her data and apps are gone.
- C is wrong: restore takes the Cloud PC back to an earlier restore point; it doesn't add RAM or CPU.
- D is wrong: fresh Start is a Windows device action that removes apps; it doesn't change the Cloud PC's size.

Rewatch: [episode 5](../notes/e05-windows-365.md)

## Question 14 — Manage and maintain

Pinecone wants its old Group Policy objects in Intune, with as little retyping as possible. Which order is right?

- A. Import the ADMX files, then assign them
- B. Create a custom OMA-URI profile for each setting
- C. Copy the policy objects into a security baseline
- D. Export each GPO as XML, import it into Group Policy analytics, then select Migrate

**Answer: D. Export each GPO as XML, import it into Group Policy analytics, then select Migrate.** Group Policy analytics shows which settings Intune supports, and Migrate creates a settings catalog policy. Microsoft calls it best effort, so review the settings.

- A is wrong: ADMX import is for third-party templates, and it's still in preview. Built-in Windows settings belong in the settings catalog.
- B is wrong: a custom OMA-URI profile per setting is exactly the retyping Pinecone wants to avoid.
- C is wrong: security baselines are Microsoft's preconfigured security settings; you can't copy GPOs into them.

Rewatch: [episode 6](../notes/e06-configuration-profiles.md)

## Question 15 — Manage and maintain

Two configuration profiles, assigned to the same laptops, set the same setting to different values. What happens?

- A. The most restrictive value wins
- B. The newest profile wins
- C. Intune reports a conflict, and you resolve it manually
- D. The device ignores both profiles

**Answer: C. Intune reports a conflict, and you resolve it manually.** When two configuration profiles disagree, Intune shows the conflict, and an admin must fix it.

- A is wrong: Most restrictive wins only between two compliance policies. Between a compliance policy and a profile, compliance wins.
- B is wrong: intune doesn't pick the newest profile; it reports the conflict.
- D is wrong: the device doesn't ignore the profiles; the conflicting setting shows as a conflict in Intune.

Rewatch: [episode 6](../notes/e06-configuration-profiles.md)

## Question 16 — Manage and maintain

Pinecone wants to block the App Store on its iPhones. Which iPhones can that restriction reach?

- A. Any enrolled iPhone
- B. Only supervised iPhones, like those from automated device enrollment
- C. Only iPhones with an app protection policy
- D. Only iPhones with account-driven user enrollment

**Answer: B. Only supervised iPhones, like those from automated device enrollment.** Since iOS thirteen, Block App Store requires a supervised device. Automated device enrollment supervises devices by default.

- A is wrong: A personal iPhone enrolled through the Company Portal isn't supervised, so the restriction doesn't apply to it.
- C is wrong: app protection policies protect data inside apps; they don't apply device restrictions.
- D is wrong: user enrollment is for personal devices, and those aren't supervised.

Rewatch: [episode 6](../notes/e06-configuration-profiles.md)

## Question 17 — Manage and maintain

Pinecone deployed a Windows elevation rules policy for the label printer driver, but the driver still can't elevate. What's most likely missing?

- A. A Remote Help session
- B. A Windows elevation settings policy that enables Endpoint Privilege Management
- C. Local admin rights for the user
- D. An App Control for Business policy

**Answer: B. A Windows elevation settings policy that enables Endpoint Privilege Management.** For rules to take effect, the device also needs an elevation settings policy that turns Endpoint Privilege Management on.

- A is wrong: remote Help is for screen sharing and remote control; it doesn't turn EPM on.
- C is wrong: Endpoint Privilege Management exists so users stay standard users. Admin rights would elevate everything they run.
- D is wrong: App Control for Business decides which apps may run at all, not which may elevate.

Rewatch: [episode 11](../notes/e11-intune-suite.md)

## Question 18 — Manage and maintain

Pinecone needs Wi-Fi certificates on its devices, but it doesn't want an on-premises certificate authority, an NDES server or the certificate connector. What do you use?

- A. Microsoft Cloud PKI, with a SCEP certificate profile
- B. A PKCS certificate profile, with the Intune certificate connector
- C. Microsoft Tunnel for MAM
- D. Windows LAPS

**Answer: A. Microsoft Cloud PKI, with a SCEP certificate profile.** Cloud PKI replaces the on-premises CA, NDES and the certificate connector. Devices get certificates through SCEP profiles, and the private key never leaves the device.

- B is wrong: That option still runs the Intune certificate connector on Pinecone's own servers, which is exactly what Pinecone wants to avoid.
- C is wrong: Microsoft Tunnel for MAM gives unenrolled phones VPN access to on-premises resources; it doesn't issue certificates.
- D is wrong: Windows LAPS manages local admin passwords, not certificates.

Rewatch: [episode 11](../notes/e11-intune-suite.md)

## Question 19 — Manage and maintain

A manager's company laptop is slow and full of preinstalled apps. He keeps using it, and the files in his home folder must stay. Which remote action do you use?

- A. Wipe
- B. Retire
- C. Fresh Start, with Retain user data on this device
- D. Autopilot reset

**Answer: C. Fresh Start, with Retain user data on this device.** Fresh Start removes apps, mainly the preinstalled ones. With retain user data, the home folder stays, and the laptop stays Entra joined.

- A is wrong: wipe resets the laptop to factory settings and removes his files too.
- B is wrong: Retire removes company data and settings, and unjoins an Entra joined laptop. The manager still needs a working company laptop.
- D is wrong: Autopilot reset removes personal files, apps and settings, so his home folder would go.

Rewatch: [episode 7](../notes/e07-remote-actions.md)

## Question 20 — Manage and maintain

A user calls the help desk: nothing works on any of her devices. You want her devices, groups, assigned policies, apps, app protection status and enrollment restrictions in one view. Where do you go?

- A. Device query, on one laptop
- B. Collect diagnostics
- C. Endpoint analytics
- D. Troubleshooting plus support, Troubleshoot, then select the user

**Answer: D. Troubleshooting plus support, Troubleshoot, then select the user.** The Troubleshooting pane starts from the user, and shows everything assigned to that person. It also points out problems with assignments, app protection and enrollment.

- A is wrong: Device query asks one Windows device about its live state, like services or BitLocker. It doesn't show a user's assignments.
- B is wrong: collect diagnostics gathers logs from one corporate Windows device; it doesn't list a user's assignments.
- C is wrong: Endpoint analytics scores startup performance and app reliability across the fleet.

Rewatch: [episode 7](../notes/e07-remote-actions.md)

## Question 21 — Protect devices

Pinecone's BitLocker policy requires device encryption, with the warning for other disk encryption disabled. Laptops where admins sign in encrypt silently, but laptops used by standard users don't. Which setting fixes it?

- A. Require a startup PIN
- B. Move the settings to the settings catalog
- C. Turn on BitLocker key rotation
- D. Allow Standard User Encryption, set to Enabled

**Answer: D. Allow Standard User Encryption, set to Enabled.** This setting lets the encryption policy work when the signed-in user is a standard user. It appears once the warning for other disk encryption is disabled.

- A is wrong: a startup PIN needs the user to type it at boot, which is the opposite of silent encryption.
- B is wrong: Learn says the settings catalog lacks the TPM startup controls for reliable silent BitLocker. Use the endpoint security profile.
- C is wrong: key rotation creates a new recovery key for an already encrypted drive; it doesn't start encryption.

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 22 — Protect devices

Pinecone wants attack surface reduction rules, but fears they'll break the label printer tool. How should it roll them out?

- A. Audit mode first, review the events, add exclusions, then block
- B. Block mode on every device, on day one
- C. Warn mode only, and never block
- D. Turn off Microsoft Defender Antivirus first

**Answer: A. Audit mode first, review the events, add exclusions, then block.** Audit mode doesn't affect users, but logs what would have been blocked. Then you add exclusions for business apps, and switch to block.

- B is wrong: Block on day one is exactly what could break the tool. Learn says to test in audit mode on a pilot group first.
- C is wrong: warn mode still blocks, and never moving to Block gives up protection; Learn's order is audit, exclusions, then Block or Warn.
- D is wrong: aSR rules need Microsoft Defender Antivirus as the active antivirus.

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 23 — Protect devices

Pinecone's App Control for Business policy should trust every app that Intune deploys from now on, without an allow rule for each one. What do you set up?

- A. Endpoint Privilege Management
- B. A security baseline
- C. The Intune Management Extension as a managed installer
- D. Trust apps with a good reputation

**Answer: C. The Intune Management Extension as a managed installer.** Apps that Intune deploys after that are tagged as trusted, and App Control lets them run. It isn't retroactive, so older apps still need allow rules.

- A is wrong: Endpoint Privilege Management decides which approved files may run elevated. App Control decides which apps may run at all.
- B is wrong: a security baseline is a group of recommended settings; it doesn't tag apps that Intune deploys.
- D is wrong: reputation-based trust covers apps with a good reputation, not every app Intune deploys (for example, an in-house tool).

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 24 — Protect devices

On a few Pinecone laptops, users and a script keep switching Microsoft Defender protection off. Which setting stops that?

- A. An antivirus exclusion
- B. Tamper protection, in an Intune antivirus policy
- C. A firewall rule
- D. Update Defender security intelligence

**Answer: B. Tamper protection, in an Intune antivirus policy.** Tamper protection prevents Microsoft Defender from being disabled. In Intune, it's in the Windows Security experience profile, under Endpoint security, Antivirus.

- A is wrong: an exclusion makes Defender skip files or folders; it doesn't stop anyone from switching protection off.
- C is wrong: firewall rules control network traffic, not Defender's own settings.
- D is wrong: Updating security intelligence only downloads the latest definitions. It doesn't lock any setting.

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 25 — Protect devices

Pinecone's Windows 11 laptops get hotpatch updates, so most months they don't restart. In April they restart anyway. Why?

- A. Hotpatch switches itself off every spring
- B. April is a baseline month, and baseline updates need a restart
- C. Delivery Optimization is set to LAN
- D. The update ring has no deadline

**Answer: B. April is a baseline month, and baseline updates need a restart.** January, April, July and October are baseline months, with a restart. The other eight months are hotpatch months, with no restart.

- A is wrong: Hotpatch stays on. The quarterly baseline is part of the design, and May is a hotpatch month again.
- C is wrong: Delivery Optimization controls how update content is shared, not whether an update restarts the device.
- D is wrong: deadlines set when a restart is forced; they don't turn a hotpatch month into a restart month.

Rewatch: [episode 9](../notes/e09-updates.md)

## Question 26 — Protect devices

Ten laptops in the Utrecht shop each download the same large update over one slow line. Delivery Optimization is set to HTTP only. Which download mode lets them share with each other on the shop network?

- A. Simple
- B. Bypass
- C. HTTP only, with a larger cache
- D. LAN

**Answer: D. LAN.** LAN, the default mode, turns on peer sharing on the same network. HTTP only turns peering off.

- A is wrong: Simple mode turns off the Delivery Optimization cloud services completely, and downloads with no peers.
- B is wrong: bypass is deprecated starting in Windows 11; Learn says not to configure it.
- C is wrong: hTTP only turns peering off, whatever the cache size.

Rewatch: [episode 9](../notes/e09-updates.md)

## Question 27 — Protect devices

Pinecone's declarative software update policy for iPhones shows Success, yet some iPhones still run the old iOS version. What does Success mean?

- A. The policy installed on the device, so check each device's OS version
- B. The update installed on every device
- C. The device is supervised
- D. The update was postponed for thirty days

**Answer: A. The policy installed on the device, so check each device's OS version.** Success only means the configuration installed on the device. To know a device really updated, check its OS version.

- B is wrong: Learn warns that Success doesn't prove the update installed. Monitor the OS version of each device instead.
- C is wrong: supervision is an enrollment property, not what the report status means.
- D is wrong: a 30-day postpone is an Android system update option, not an Apple report status.

Rewatch: [episode 9](../notes/e09-updates.md)

## Question 28 — Manage apps

Intune keeps reporting Pinecone's label tool as not installed, even on laptops where it is. Which part of the Win32 app tells Intune whether it's there?

- A. Requirements
- B. The install command
- C. Detection rules
- D. Dependencies

**Answer: C. Detection rules.** Detection rules check for an MSI product code, a file, a registry value, or a script result. Every Win32 app needs at least one.

- A is wrong: Requirements decide whether a device may install the app, like architecture or minimum Windows version. They don't detect it.
- B is wrong: the install command runs the installer; it doesn't check whether the app is present.
- D is wrong: dependencies are other apps that must install first.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 29 — Manage apps

Version two of the label tool is ready. It must replace version one on every shop laptop. Which Win32 app relationship do you add?

- A. Supersedence
- B. A dependency
- C. An app configuration policy
- D. An assignment filter

**Answer: A. Supersedence.** Supersedence updates or replaces an existing Win32 app, with a newer version or with a different app.

- B is wrong: A dependency is an app that must install first. It doesn't replace anything.
- C is wrong: app configuration policies supply settings to mobile apps; they don't replace Win32 apps.
- D is wrong: assignment filters narrow which devices get an assignment; they don't replace an app.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 30 — Manage apps

Microsoft 365 Apps must install during Autopilot, while the Enrollment Status Page tracks it. Sometimes the ESP fails. What does Microsoft recommend?

- A. Remove Microsoft 365 Apps from Autopilot
- B. Keep the Microsoft 365 Apps app type, with a longer timeout
- C. Install it from the Company Portal after setup
- D. Deploy Microsoft 365 Apps as a Win32 app

**Answer: D. Deploy Microsoft 365 Apps as a Win32 app.** The built-in app type isn't installed by the Intune Management Extension, so it can start while a tracked Win32 app is installing, and the ESP fails.

- A is wrong: removing Office from Autopilot doesn't meet the requirement that it installs during setup.
- B is wrong: A longer timeout doesn't stop the two installs from clashing. As a Win32 app, Office goes through the Intune Management Extension too.
- C is wrong: the requirement is that Office installs during Autopilot, tracked by the ESP; Company Portal apps wait for users.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 31 — Manage apps

You install Microsoft 365 Apps with the Office Deployment Tool and a configuration XML file. Which mode installs them?

- A. Download mode (/download)
- B. Configure mode (/configure)
- C. Customize mode (/customize)
- D. Help mode (/help)

**Answer: B. Configure mode (/configure).** Setup with slash configure and your XML file installs the products and languages in it. Download mode only fetches the files.

- A is wrong: download mode only fetches the products and languages for a later install.
- C is wrong: Customize mode applies new app preferences to computers that already have Microsoft 365 Apps. It doesn't install them.
- D is wrong: help mode shows the tool's command-line help.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 32 — Manage apps

Shop staff shouldn't get Outlook email or Teams notifications on their phones after work hours. What do you create in Intune?

- A. An app protection policy, with conditional launch
- B. A device restrictions profile
- C. A Quiet Time policy
- D. A Conditional Access policy

**Answer: C. A Quiet Time policy.** Quiet Time policies mute Outlook email and Teams notifications on iOS and Android, for a date range, or on chosen days and hours.

- A is wrong: Conditional launch checks the app at sign-in, and can block access or wipe company data. It doesn't schedule notifications.
- B is wrong: device restrictions profiles configure the device; Quiet Time policies are what mute Outlook and Teams notifications.
- D is wrong: Conditional Access decides access at sign-in; it doesn't mute notifications on a schedule.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 33 — Manage apps

A Win32 app fails to install on one laptop. Which log on the device covers app installs, applicability and detection?

- A. The Windows Update log
- B. The Company Portal settings page
- C. The Delivery Optimization log
- D. AppWorkload.log (IntuneManagementExtension\Logs)

**Answer: D. AppWorkload.log (IntuneManagementExtension\Logs).** The Intune Management Extension keeps its logs under ProgramData. AppWorkload.log is the main app log: check-ins, installs, applicability and detection.

- A is wrong: The Windows Update log covers Windows updates. Win32 apps are installed by the Intune Management Extension, which keeps its own logs.
- B is wrong: the Company Portal shows the user's apps; the install details are in the Intune Management Extension logs.
- C is wrong: Delivery Optimization logs cover content sharing, not app detection or applicability.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 34 — Manage apps

Pinecone wants Outlook preconfigured on staff's personal phones, which aren't enrolled. Which app configuration policy type do you choose?

- A. Managed apps
- B. Managed devices
- C. A device configuration profile
- D. An enrollment profile

**Answer: A. Managed apps.** The managed apps channel works whether or not the device is enrolled, for apps built with the Intune App SDK, like Outlook.

- B is wrong: Managed devices sends settings over the device management channel, so the device must be enrolled.
- C is wrong: device configuration profiles configure enrolled devices, not app settings on unenrolled phones.
- D is wrong: enrollment profiles set up device enrollment; these phones won't be enrolled.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 35 — Automate and monitor

Pinecone's Graph PowerShell script reads devices with DeviceManagementManagedDevices.Read.All. Now it must also start a sync on stale laptops, with Sync-MgDeviceManagementManagedDevice. Which permission does that need?

- A. …ManagedDevices.Read.All is enough
- B. User.ReadWrite.All
- C. …PrivilegedOperations.All
- D. …Configuration.Read.All

**Answer: C. …PrivilegedOperations.All.** The sync action needs the PrivilegedOperations permission, delegated or application. Read.All only lets the script read.

- A is wrong: A sync is an action on the device, not a read, so a read-only permission isn't enough.
- B is wrong: user.ReadWrite.All is about user objects, not managed devices.
- D is wrong: DeviceManagementConfiguration.Read.All reads configuration policies; it doesn't allow device actions.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

## Question 36 — Automate and monitor

A Graph PowerShell script must run every night as a scheduled task, with nobody signed in. How should it connect?

- A. Connect-MgGraph with Scopes, signing in as an admin each night
- B. App-only access, with an app registration and a certificate
- C. Through the Company Portal
- D. A Remediations script with a stored admin password

**Answer: B. App-only access, with an app registration and a certificate.** App-only access is for unattended scripts. You register an app in Microsoft Entra ID, add a certificate, grant application permissions with admin consent, and connect with the app's ID.

- A is wrong: Scopes are delegated permissions for a signed-in user. At night, there's nobody there to sign in.
- C is wrong: the Company Portal is the end-user app; it has nothing to do with script authentication.
- D is wrong: remediations run detection and remediation scripts on devices; storing an admin password in a script is never the answer.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

## Question 37 — Automate and monitor

Pinecone wants its startup score compared with its own score from today, not with other organizations. What do you do?

- A. Nothing. The built-in baseline already uses Pinecone's own scores
- B. Run a Remediations script
- C. Export the report to CSV every day
- D. Create a custom baseline in the Endpoint analytics settings

**Answer: D. Create a custom baseline in the Endpoint analytics settings.** Under Settings, Baseline, you create a new baseline from current metrics. A metric that drops below it by more than the regression threshold, ten percent by default, is flagged as regressed.

- A is wrong: The built-in baseline is the median of all organizations, not Pinecone's own history.
- B is wrong: remediations detect and fix device issues; they don't create a baseline.
- C is wrong: a daily export is manual tracking; Endpoint analytics already supports your own baseline and flags regressions.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

## Question 38 — Automate and monitor

Pinecone wants to use Remediations on its Windows laptops. Which license must the users of those devices have?

- A. Windows Enterprise E3 or E5
- B. Microsoft Entra ID P1, on its own
- C. Windows Pro, which comes with the laptops
- D. Microsoft 365 Apps for business

**Answer: A. Windows Enterprise E3 or E5.** Remediations need Windows Enterprise E3 or E5, Windows Education A3 or A5, or Windows VDA per user. Microsoft 365 F3, E3 and E5 include Windows Enterprise.

- B is wrong: Microsoft Entra ID P1 isn't one of the licenses Learn lists for Remediations.
- C is wrong: Windows Pro isn't on the list of licenses for Remediations.
- D is wrong: Microsoft 365 Apps for business isn't one of the licenses Learn lists for Remediations.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

## Question 39 — Automate and monitor

Pinecone wants its own dashboards on Intune audit and compliance data, queried with KQL. What do you set up first?

- A. A custom compliance policy
- B. Diagnostic settings that send Intune logs to a Log Analytics workspace
- C. Device query on every laptop
- D. A compliance notification email

**Answer: B. Diagnostic settings that send Intune logs to a Log Analytics workspace.** Under Reports, Diagnostic settings, you send audit logs, operational logs, device compliance and device data to Log Analytics. Then you query them with KQL, and build workbooks.

- A is wrong: custom compliance adds your own compliance checks; it doesn't route logs anywhere.
- C is wrong: Device query asks one Windows device in near real time. It doesn't collect tenant-wide audit or compliance logs.
- D is wrong: a noncompliance email notifies a user or admins; it doesn't store data you can query.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

## Question 40 — Automate and monitor

Many Pinecone laptops suddenly fail to sync with Intune. Before you open a support ticket, you want to know if Microsoft has an active incident affecting your tenant. Where do you look?

- A. Endpoint analytics
- B. The Troubleshooting pane, for one user
- C. Tenant administration, Tenant status, Service health and message center
- D. The Windows feature update report

**Answer: C. Tenant administration, Tenant status, Service health and message center.** Service health shows active incidents and advisories that affect your tenant. The message center shows announcements from the Intune team.

- A is wrong: Endpoint analytics measures device performance, not Microsoft service incidents.
- B is wrong: The Troubleshooting pane shows one user's devices and assignments. It doesn't show Microsoft's service incidents.
- D is wrong: the feature update report shows Windows update states for devices.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

---

32 or more right: you're ready to book the exam. 24 to 31: close — rewatch the episodes named on the questions you
missed. Below 24: rewatch the areas where you lost the most points, then take the set again. Microsoft also has a
free official practice assessment for MD-102, linked from the
[Endpoint Administrator Associate certification page](https://learn.microsoft.com/en-us/credentials/certifications/modern-desktop/).
