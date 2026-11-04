# Practice set 2 explained — Protect devices, manage apps, automation and monitoring

Video: *MD-102 Practice Questions: Endpoint Security, Updates, Apps and Automation* · Covers exam areas 3, 4 and 5

Original questions written against Microsoft's skills outline, not real exam questions. Try each one before you
read the answer. The "Rewatch" line points to the course episode that teaches it (8 = endpoint security,
9 = updates, 10 = apps, 12 = automation and monitoring). Notes for every episode are in [`../notes/`](../notes/).

Answer key: 1 C · 2 A · 3 D · 4 B · 5 A · 6 C · 7 B · 8 D · 9 A · 10 C · 11 B · 12 D · 13 C · 14 A · 15 B

---

## Question 1 — Endpoint security

A Pinecone laptop asks for its BitLocker recovery key. The user wants to get the key herself, from her phone,
without calling the help desk. Where can she find it?

- A. On a sticker under the laptop
- B. In the Microsoft Defender portal
- C. In the Company Portal
- D. Nowhere: only an Intune admin can read it

**Answer: C. In the Company Portal.** Intune supports self-service key recovery there (the website, and the iOS
and macOS apps). Pinecone's disk encryption policy saved the key to Microsoft Entra ID.

- A is wrong: the key is generated on the device and saved to Entra ID; nothing puts it on a sticker.
- B is wrong: the Defender portal is where security teams investigate threats and triage incidents, not where users
  recover keys.
- D is wrong: users can view keys for devices they own, unless an admin turns that off in Microsoft Entra ID.
  (My Account, under Devices, is another self-service option.)

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 2 — Endpoint security

Pinecone wants Microsoft's recommended Windows security settings as one preconfigured package, without picking
hundreds of settings by hand. What do you deploy?

- A. A security baseline
- B. A custom compliance policy
- C. An app configuration policy
- D. An assignment filter

**Answer: A. A security baseline.** It's a preconfigured group of Windows settings recommended by Microsoft's
security teams. Its defaults are strict, so test on a pilot group and check for conflicts.

- B is wrong: a compliance policy only checks and reports; it sets nothing, and you'd write every rule yourself.
- C is wrong: app configuration supplies settings to an app, not Windows security settings.
- D is wrong: a filter only narrows who receives an assignment; it contains no settings.

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 3 — Endpoint security

Malware often arrives as an Office document that starts a script. Which Intune endpoint security policy targets
that behavior?

- A. Firewall
- B. Antivirus
- C. Disk encryption
- D. Attack surface reduction rules

**Answer: D. Attack surface reduction rules.** They target behaviors malware uses, like scripts and executables
started from Office apps (for example "Block all Office applications from creating child processes").

- A is wrong: the firewall controls network traffic (ports, programs, protocols), not what an Office app starts.
- B is wrong: antivirus detects malware; ASR rules block the behavior itself, even when the file isn't known
  malware.
- C is wrong: disk encryption protects data at rest on a lost device; it doesn't stop a script running.

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 4 — Endpoint security

Intune and Microsoft Defender for Endpoint are already connected. How do you onboard Pinecone's Windows laptops
to Defender for Endpoint?

- A. With a compliance policy
- B. With an endpoint detection and response policy, set to Auto from connector
- C. With a Windows Autopilot profile
- D. With a feature update policy

**Answer: B.** Once the connection is enabled, Intune receives the onboarding package automatically, and the EDR
policy deploys it.

- A is wrong: a compliance policy can read Defender's machine risk score, but it can't deploy the onboarding
  package.
- C is wrong: an Autopilot profile sets up new devices (join, enrollment, OOBE); it doesn't onboard to Defender.
- D is wrong: a feature update policy only picks the Windows version.

Rewatch: [episode 8](../notes/e08-endpoint-security.md)

## Question 5 — Device updates

Pinecone's laptops must stay on one Windows 11 version until IT has tested the next one. Update rings already
handle the monthly patches. What keeps the version in place?

- A. A feature update policy
- B. Pausing feature updates in the update ring
- C. An expedite policy
- D. Delivery Optimization

**Answer: A. A feature update policy.** It locks devices to the Windows version you choose; the ring still
handles restarts and deadlines.

- B is wrong: pause is an emergency brake for a bad update (up to 35 days, then it expires), not a version lock.
  A feature update policy even needs feature updates unpaused in the ring.
- C is wrong: expedite pushes one urgent quality update; it doesn't hold a version.
- D is wrong: Delivery Optimization only saves bandwidth by sharing downloads between peers.

Rewatch: [episode 9](../notes/e09-updates.md)

## Question 6 — Device updates

A critical Windows security update is out, and Pinecone's update rings would defer it for a week. You want it
installed as soon as possible, without changing the rings. What do you use?

- A. A new update ring with no deferral
- B. A feature update policy
- C. An expedite policy for that quality update
- D. An Autopilot reset

**Answer: C.** Expedited updates install as soon as possible, bypassing deferral settings for that update only;
future quality updates deploy as before.

- A is wrong: a new ring means moving devices between groups, and it changes every future update too.
- B is wrong: feature update policies pick the Windows version; a security fix is a quality update.
- D is wrong: Autopilot reset resets the device; it doesn't install a specific update.

Rewatch: [episode 9](../notes/e09-updates.md)

## Question 7 — Apps

Pinecone's mapping tool ships as a setup file with a folder of support files. Before you can add it to Intune as
a Win32 app, what do you do?

- A. Upload the setup file on its own
- B. Package the folder into an .intunewin file with the Microsoft Win32 Content Prep Tool
- C. Turn it into an app protection policy
- D. Publish it to Managed Google Play

**Answer: B.** The tool compresses the whole setup folder into one .intunewin file. The app must also install
silently.

- A is wrong: the Win32 app type only accepts an .intunewin file, and a lone setup file would leave its support
  files behind.
- C is wrong: app protection protects data inside apps; it doesn't deploy anything.
- D is wrong: Managed Google Play is for Android apps.

Rewatch: [episode 10](../notes/e10-apps.md) · command: [`commands/e10-win32-package.ps1`](../commands/e10-win32-package.ps1)

## Question 8 — Apps

Shop iPads are enrolled with automated device enrollment, and nobody signs in to the App Store on them. A paid
app must install on all of them. What do you do?

- A. Make it available to users in the Company Portal
- B. Use an app configuration policy
- C. Add it through Managed Google Play
- D. Buy licenses in Apple Business Manager, upload the location token to Intune, and assign with device licensing

**Answer: D.** With device licensing, no App Store sign-in is needed; each device uses one license.

- A is wrong: available apps wait for each user to install them; Pinecone needs a required install on every iPad,
  with one license per device.
- B is wrong: app configuration supplies settings to an app that's already there; it doesn't buy or install it.
- C is wrong: Managed Google Play is for Android.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 9 — Apps

Staff read Pinecone email in Outlook on their own phones, which aren't enrolled. You must stop them pasting
company data into personal apps. What do you use?

- A. An app protection policy
- B. A device compliance policy
- C. A device configuration profile
- D. A device wipe

**Answer: A. An app protection policy.** It works without enrolling the device and protects data inside managed
apps, for example by restricting cut, copy and paste.

- B is wrong: a compliance policy needs an enrolled device to check, and compliance never controls copy and paste.
- C is wrong: configuration profiles also need an enrolled device.
- D is wrong: a wipe needs an enrolled device and deletes everything, including personal data; it doesn't control
  pasting.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 10 — Apps

Pinecone's iPhones are enrolled. Outlook should arrive already set up with each user's work account, so nobody
types settings. What do you use?

- A. An app protection policy
- B. A compliance policy
- C. An app configuration policy
- D. A scope tag

**Answer: C. An app configuration policy.** App configuration supplies settings to the app; app protection
controls what users can do with the data inside it.

- A is wrong: app protection can require a PIN or block copy and paste, but it never fills in the work account.
- B is wrong: a compliance policy checks the device; it doesn't configure apps.
- D is wrong: scope tags control which admins see an object.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 11 — Apps

Personal phones should reach Pinecone email only from apps that have an Intune app protection policy. Which
Conditional Access grant control fits?

- A. Require device to be marked as compliant
- B. Require app protection policy
- C. Require multifactor authentication
- D. Block access

**Answer: B. Require app protection policy.** Access is granted only from apps protected by Intune, without
enrollment (app-based Conditional Access).

- A is wrong: a compliant device needs an enrolled device; Pinecone's personal phones aren't enrolled, so they'd
  lose email completely.
- C is wrong: MFA checks the user, not whether the app is protected.
- D is wrong: it blocks email on personal phones entirely instead of allowing it from protected apps.

Rewatch: [episode 10](../notes/e10-apps.md)

## Question 12 — Automation

A script must list Pinecone's Intune managed devices with the Microsoft Graph PowerShell SDK, using least
privilege. Which scope do you pass to `Connect-MgGraph`?

- A. `User.Read.All`
- B. `Group.ReadWrite.All`
- C. `DeviceManagementManagedDevices.ReadWrite.All`
- D. `DeviceManagementManagedDevices.Read.All`

**Answer: D.** It's the least privileged permission for reading managed devices.

- A is wrong: it reads users, not Intune managed devices.
- B is wrong: it's about groups, and it's a write permission.
- C is wrong: ReadWrite also works, but it lets the script update and delete devices. A read-only script gets
  read-only access.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md) · script: [`e12-automation/01-find-quiet-devices.ps1`](../e12-automation/01-find-quiet-devices.ps1)

## Question 13 — Automation

Pinecone's laptops must run an in-house agent that the built-in compliance settings can't check. How do you make
it part of compliance?

- A. Use a Remediations script
- B. Use an assignment filter
- C. Custom compliance, with a PowerShell discovery script and a JSON file of rules
- D. A device configuration profile

**Answer: C.** The script reports values, the JSON file defines what's compliant, and Conditional Access uses the
result like any built-in setting.

- A is wrong: Remediations detect and fix problems, but their results aren't compliance settings, so Conditional
  Access never sees them.
- B is wrong: a filter targets assignments by device property; it doesn't evaluate compliance.
- D is wrong: a configuration profile sets things; it doesn't check them.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md) · files: [`e12-automation/03-custom-compliance-discovery.ps1`](../e12-automation/03-custom-compliance-discovery.ps1), [`03-custom-compliance-rules.json`](../e12-automation/03-custom-compliance-rules.json)

## Question 14 — Monitoring

A print service on some laptops keeps stopping. You want Intune to check it every day and restart it when it's
down. What do you use?

- A. Remediations, with a detection script and a remediation script on a daily schedule
- B. A compliance policy
- C. Collect diagnostics
- D. An Autopilot reset

**Answer: A.** The remediation script only runs when the detection script exits with code 1.

- B is wrong: a compliance policy can mark the laptop noncompliant, but it can't restart the service. It checks;
  it doesn't fix.
- C is wrong: collect diagnostics gathers logs for troubleshooting; it doesn't fix anything or run on a schedule.
- D is wrong: Autopilot reset resets the whole device, far more than restarting one service.

Rewatch: [episode 12](../notes/e12-automation-monitoring.md) · scripts: [`e12-automation/04-remediation-detect-spooler.ps1`](../e12-automation/04-remediation-detect-spooler.ps1), [`05-remediation-fix-spooler.ps1`](../e12-automation/05-remediation-fix-spooler.ps1)

## Question 15 — Monitoring

Users say their laptops take ages to reach a usable desktop after power-on. Which Endpoint analytics report shows
boot and sign-in times?

- A. App reliability
- B. Startup performance
- C. The encryption report
- D. The feature update report

**Answer: B. Startup performance.** Its startup score combines a boot score (power-on to sign-in) and a sign-in
score (sign-in until the desktop responds).

- A is wrong: app reliability tracks app crashes and mean time to failure, not boot and sign-in times.
- C is wrong: the encryption report shows encryption readiness and status (episode 8).
- D is wrong: the feature update report shows Windows version update states (episode 9).

Rewatch: [episode 12](../notes/e12-automation-monitoring.md)

---

Twelve or more right: these three areas are in good shape. Fewer: rewatch episodes 8, 9, 10 and 12. Microsoft
also has a free official practice assessment for MD-102, linked from the
[Endpoint Administrator Associate certification page](https://learn.microsoft.com/en-us/credentials/certifications/modern-desktop/).
