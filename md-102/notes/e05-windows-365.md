# Episode 5 — Windows 365 Cloud PCs in Intune

Video: *Windows 365 Cloud PCs in Intune: Provisioning Policies, Networks and Images* · Exam area: Manage and maintain devices

## Pinecone scenario

Pinecone hires twenty seasonal support agents for the winter sale and their laptops are stuck in a shipping
container. They start on Monday anyway, on Windows 365 Cloud PCs managed in the same Intune admin center as every
laptop. The old Remote Desktop Services farm is replaced by one license per user.

## Key steps

- [ ] Give each user a **Windows 365 license** (the license decides the Cloud PC size).
- [ ] Provisioning policy: **Devices › Provision Cloud PCs › Provisioning policies › Create policy**.
  - [ ] General: name, license type **Enterprise**, join type (**Microsoft Entra join** or hybrid join), network
        (Microsoft hosted network + geography + "All default regions within the geography", or an Azure network
        connection), **Use Microsoft Entra single sign-on**.
  - [ ] Image: gallery or custom.
  - [ ] Configuration: language and region, optional device name template (5 to 15 characters, `%RAND:Y%` with
        Y of at least 5; [`commands/e04-e05-device-name-templates.txt`](../commands/e04-e05-device-name-templates.txt)),
        optional Windows Autopatch.
  - [ ] Assignments: Microsoft Entra **user** groups (nested groups aren't supported).
- [ ] Azure network connection (only when needed): **Devices › Provision Cloud PCs › Azure network connection ›
      Create** › subscription, resource group, virtual network, subnet; for hybrid join also the AD domain name,
      optional OU and an account that can join computers. Wait for the **health checks** to pass.
- [ ] Custom image (only if no gallery image fits): **Devices › Provision Cloud PCs › Custom images › Add**
      (managed image or Azure Compute Gallery).
- [ ] Manage the Cloud PCs like any device: **Devices › All devices**; same configuration profiles, compliance,
      apps, updates; start from the Windows 365 security baseline on pilot Cloud PCs.

What Windows 365 does by itself after license + policy: allocate Azure capacity in the region › create the VM
and attach the network › join Microsoft Entra ID › enroll in Intune without user credentials › make the user the
primary user. On failure it retries twice; after three failures the Cloud PC is marked **Failed** (retry once the
cause is fixed).

## Decisions

| | Microsoft hosted network | Azure network connection (ANC) |
|---|---|---|
| Who manages the network | Microsoft | you (your Azure virtual network) |
| Azure subscription | not needed | needed |
| Join types | Entra join only | Entra join **or hybrid join** |
| On-premises access | VPN or private access over the internet | direct, from your VNet |
| Recommendation | Microsoft's choice for most deployments | when you need hybrid join or direct on-premises access |

| Image | Who keeps it current | Notes |
|---|---|---|
| Gallery | Microsoft (monthly) | Windows Enterprise, with or without Microsoft 365 Apps; new Cloud PCs get the latest, existing ones on reprovision |
| Custom | you | managed image or Azure Compute Gallery; generalized, generation 2, single-session, never domain joined or Intune enrolled |

| Cloud PC action | Effect |
|---|---|
| Resize | changes RAM, CPU, storage; **keeps** data; can't shrink the disk; user disconnected |
| Restore | back to an earlier restore point; later changes lost, OneDrive data stays |
| Reprovision | wipes and rebuilds from the **current** policy; all data, apps, customizations deleted |

## Exam traps

- **A license alone is not enough**: the user must also be in a group assigned to a provisioning policy.
- **Hybrid join always means an Azure network connection**; Entra join can use either network.
- Each Cloud PC license uses one provisioning policy; if a user is in two, the **first assigned** wins.
- Editing a policy doesn't touch existing Cloud PCs; changes apply to Cloud PCs provisioned or reprovisioned
  afterward.
- A provisioning policy is **not** a configuration profile: it decides how the Cloud PC is built (license type,
  join type, network, image, region, name). Settings and apps come from normal Intune policies.
- A policy can list several ANCs; the **first healthy** one is used. An ANC must pass health checks first.
- Prefer gallery images and layer apps with Intune; a custom image is yours to keep updated.
- Users connect at windows365.microsoft.com or with the app on Windows, Mac, iOS and Android; billing is per
  user per month.

## Sources

- MD-102 study guide: https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/md-102
- What is Windows 365 Enterprise?: https://learn.microsoft.com/en-us/windows-365/enterprise/overview
- Provisioning in Windows 365: https://learn.microsoft.com/en-us/windows-365/enterprise/provisioning
- Automated provisioning steps: https://learn.microsoft.com/en-us/windows-365/enterprise/automated-provisioning-steps
- Create provisioning policies: https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy
- Deployment options: https://learn.microsoft.com/en-us/windows-365/enterprise/deployment-options
- Network deployment options: https://learn.microsoft.com/en-us/windows-365/enterprise/windows-365-network-deployment-options
- Azure network connections: https://learn.microsoft.com/en-us/windows-365/enterprise/azure-network-connections · https://learn.microsoft.com/en-us/windows-365/enterprise/create-azure-network-connection
- Device images: https://learn.microsoft.com/en-us/windows-365/enterprise/device-images · https://learn.microsoft.com/en-us/windows-365/enterprise/add-device-images
- Intune as the management plane for Windows 365: https://learn.microsoft.com/en-us/windows-365/enterprise/windows-365-deployment-guidance-management
- Remotely manage Cloud PCs: https://learn.microsoft.com/en-us/windows-365/enterprise/remotely-manage-cloud-pc
- Resize / Restore / Reprovision: https://learn.microsoft.com/en-us/windows-365/enterprise/resize-cloud-pc · https://learn.microsoft.com/en-us/windows-365/enterprise/restore-overview · https://learn.microsoft.com/en-us/windows-365/enterprise/reprovision-cloud-pc
- Windows 365 role-based access: https://learn.microsoft.com/en-us/windows-365/enterprise/role-based-access
