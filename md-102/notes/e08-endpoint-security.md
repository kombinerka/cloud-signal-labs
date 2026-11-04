# Episode 8 — Intune endpoint security: BitLocker, ASR, Defender, App Control

Video: *Intune Endpoint Security: BitLocker, ASR Rules, Defender and App Control* · Exam area: Protect devices

## Pinecone scenario

A sales rep leaves a laptop on a train with the customer list on it. Disaster or shrug? It depends on Endpoint
security: disk encryption and recovery keys, antivirus and firewall, attack surface reduction and baselines,
Defender for Endpoint, and App Control for Business.

## Key steps

- [ ] Silent BitLocker: **Endpoint security › Disk encryption › Create policy › Windows › BitLocker**:
      Require Device Encryption = Enabled; Allow Warning For Other Disk Encryption = Disabled; Allow Standard User
      Encryption = Enabled › **Assignments** (sales laptops group) › Review + create
      ([`commands/e07-e08-bitlocker-settings.txt`](../commands/e07-e08-bitlocker-settings.txt)). macOS: FileVault
      in the same node.
- [ ] Recovery keys: saved to Microsoft Entra ID; help desk finds them on the device page under **Recovery keys**
      (every reveal audited). Self-service: **My Account › Devices › View BitLocker Keys**, the Company Portal
      website, or the Company Portal app for iOS/macOS. Check the **encryption report** (readiness, status, TPM
      version).
- [ ] Antivirus: **Endpoint security › Antivirus** (Windows profiles: Microsoft Defender Antivirus, Defender
      Antivirus exclusions, Windows Security experience, Defender Update controls). Turn on tamper protection;
      keep exclusions small. Monitor: Unhealthy endpoints, Antivirus agent status, Detected malware.
- [ ] Firewall: **Endpoint security › Firewall** (macOS firewall, Windows Firewall, Windows Firewall rules).
- [ ] Attack surface reduction: **Endpoint security › Attack surface reduction** (Attack Surface Reduction Rules,
      Device Control, Exploit Protection). Each rule: **Audit first**, add exclusions for real business apps,
      then Block.
- [ ] Security baselines: **Endpoint security › Security baselines** (Windows, Defender for Endpoint, Microsoft
      Edge, Windows 365, Microsoft 365 Apps). Test on a pilot group, customize what breaks.
- [ ] Defender for Endpoint: Defender portal **Advanced features › Intune connection = On** › Intune **Endpoint
      security › Microsoft Defender for Endpoint** shows Enabled › turn on connecting Windows devices for
      compliance policy evaluation › **EDR policy** with package type **Auto from connector** (or Deploy
      preconfigured policy) › check **EDR Onboarding Status** › compliance rule "at or under the machine risk
      score" › Conditional Access requiring a compliant device.
- [ ] Triage in the Defender portal: **Investigation and response › Incidents and alerts** › severity, affected
      devices/users, still active? › device page: isolate, antivirus scan, collect investigation package,
      restrict app execution › assign owner, tags, notes, status, classify. Fix is a setting? Send a **security
      task** to Intune.
- [ ] App Control for Business: **Endpoint security › App Control for Business** › your own XML or built-in
      controls (trust Windows components and Store apps, good reputation, managed installers) › **Audit only**
      first, then enforce. Set the Intune Management Extension as managed installer.

## Decisions

| Policy type | Job |
|---|---|
| Endpoint security policy | focused settings for one security feature (precise control) |
| Device configuration profile | everything else (Wi-Fi, email...) |
| Security baseline | Microsoft's recommended starting point (mostly strictest values) |
| Compliance policy | only checks, never sets |

| ASR rule mode | Effect |
|---|---|
| Audit | logs what would be blocked, lets it run |
| Block | stops it |
| Warn | blocks; the 24-hour unblock now requires admin approval |

| On-premises | Intune |
|---|---|
| Defender/firewall GPOs | antivirus and firewall policies |
| MBAM for recovery keys | disk encryption saving keys to Entra ID |
| AppLocker | App Control for Business |
| Security Compliance Toolkit GPO baselines | Intune security baselines |

## Exam traps

- **Settings catalog is not the tool for silent BitLocker** (lacks the TPM startup controls); use the endpoint
  security profile. Silent needs Entra joined or hybrid joined, TPM, UEFI, Secure Boot, Windows RE.
- Users **can** view keys for devices they own by default; an Entra setting restricts it.
- **Mac antivirus needs Defender for Endpoint installed** on the Mac. Every antivirus exclusion is a place that
  isn't scanned; tamper protection stops users, scripts and malware switching protection off.
- ASR rules need Microsoft Defender Antivirus as the **active** antivirus. ASR blocks the behavior (for example
  "Block all Office applications from creating child processes"), even for files that aren't known malware.
- For the same settings use endpoint security policies **or** a baseline, not both. New baseline version: old
  profiles become read-only; move them.
- EDR onboarding only turns on **telemetry**; it doesn't configure antivirus, firewall or ASR.
- A compliance policy can **read** the machine risk score but can't deploy the onboarding package.
- Zero Trust: verify explicitly, least privilege, **assume breach** (shrink what an attacker can reach).
- App Control decides **which apps may run**; Endpoint Privilege Management (episode 11) decides which approved
  apps may run **elevated**. Managed installer trust isn't retroactive.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- Endpoint security policies: https://learn.microsoft.com/en-us/intune/device-security/endpoint-security-policies
- Encrypt Windows devices with BitLocker: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/encrypt-bitlocker-windows
- BitLocker recovery process: https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/recovery-process
- Get the recovery key (Company Portal): https://learn.microsoft.com/en-us/intune/user-help/security/collect-recovery-key-windows
- Encryption report: https://learn.microsoft.com/en-us/intune/intune-service/protect/encryption-monitor
- Antivirus policies: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/antivirus
- Firewall policies: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/firewall
- Attack surface reduction policies: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/attack-surface-reduction
- ASR rules overview: https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-overview
- Zero Trust with Intune: https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/zero-trust-with-microsoft-intune
- Security baselines: https://learn.microsoft.com/en-us/intune/device-security/security-baselines/overview
- Defender for Endpoint integration: https://learn.microsoft.com/en-us/intune/device-security/microsoft-defender/configure-integration
- EDR policy: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/deploy-edr
- Investigate and respond (training): https://learn.microsoft.com/en-us/training/modules/implement-defender-endpoint-intune/06-investigate-respond
- Monitor and triage incidents (training): https://learn.microsoft.com/en-us/training/modules/implement-defender-endpoint-intune/07-monitor-triage-incidents
- App Control for Business: https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/manage-app-control
