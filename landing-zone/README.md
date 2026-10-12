# A landing zone you can read in ten minutes

Companion code for the Cloud Signal explainer on **Azure landing zones** (Orchard's prepared place to build).

An empty subscription gives a team somewhere to put resources, but no agreement about access, connections or who
investigates a change. A landing zone supplies that foundation: the **platform team** owns shared guardrails and
capabilities, the **workload team** owns its application inside them.

This is a deliberately small version to learn the structure from, in **Terraform** and **Bicep**. For a real
platform, start from the official [Azure Landing Zones accelerator](https://azure.github.io/Azure-Landing-Zones/accelerator/)
(Terraform: [`Azure/avm-ptn-alz/azurerm`](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest);
Bicep: the ALZ Bicep accelerator), which adds the full policy set, logging, Defender and much more.

## What it builds

```
Tenant root group
└── Orchard
    ├── Platform
    │   ├── Management       ← management subscription
    │   ├── Connectivity     ← connectivity subscription: hub network
    │   ├── Identity
    │   └── Security
    ├── Landing zones
    │   ├── Corp             ← Orchard production (policy: no public IPs)
    │   └── Online
    ├── Sandbox
    └── Decommissioned
Policy at Orchard: allowed locations, inherited by everything below
```

| | Terraform | Bicep |
|---|---|---|
| Management groups, placement, policies, hub | [`terraform/main.tf`](terraform/main.tf) | [`bicep/main.bicep`](bicep/main.bicep) (+ modules) |
| Your values | [`terraform/example.tfvars`](terraform/example.tfvars) | [`bicep/main.bicepparam`](bicep/main.bicepparam) |
| Deploy | `terraform apply -var-file=example.tfvars` | `az deployment tenant create -l westeurope -f bicep/main.bicep -p bicep/main.bicepparam` |

## Three things the video stresses

- **Entra ID is not the management group tree.** The directory holds users, groups and app identities; management
  groups organise subscriptions underneath it.
- **Placement is governance, not networking.** Moving Orchard's subscription under *Corp* changes which policies
  apply. It doesn't move a packet or create a network; connectivity is its own design (spokes peer to the hub, see
  [hub-spoke-peering](../hub-spoke-peering/)).
- **The four platform subscriptions are the accelerator's recommendation**, not four services every organisation
  must build. The *Identity* subscription is for things like domain services, not for the Entra directory itself.

## Permissions

Creating management groups and assigning policy at that level needs Management Group Contributor (and Resource
Policy Contributor) at the tenant root group or the parent you choose; moving subscriptions needs Owner on them. Try
it in a test tenant first.

## Sources

- Cloud Adoption Framework: What is an Azure landing zone? https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/
- Management groups design area: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups
- Azure Landing Zones accelerator: https://azure.github.io/Azure-Landing-Zones/accelerator/
