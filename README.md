# Cloud Signal Labs

Working examples for the videos on the **Cloud Signal** YouTube channel: Azure, DevOps, DevSecOps, FinOps and
Kubernetes, explained in practice.

Every folder belongs to a video, has its own README, and can be used on its own. Explainers get a bigger folder
that follows the video step by step; Shorts get a small one for the single idea. Where infrastructure code comes up,
you get **both Terraform and Bicep**. Where a pipeline comes up, you get **GitHub Actions, Azure Pipelines and GitLab
CI**. Use the one your team runs.

## Explainers (5-15 min): bigger folders, step by step

| Folder | Video | What you get |
|---|---|---|
| [azure-takeover](azure-takeover/) | You Inherited a Messy Azure Setup. Don't Start With Terraform. | discovery queries, "what is managed" comparison, safety basics, the Terraform export loop **and** the Bicep deployment-stack option, pipelines on all three platforms |
| [landing-zone](landing-zone/) | Azure Landing Zones: The Foundation Before the Workload | management groups, subscription placement, inherited policies and a hub network, in Terraform and Bicep |
| [oidc-deploy](oidc-deploy/) | Deploy to Azure Without a Stored Secret (and the 2-minute version) | identity + federated credential in Terraform, Bicep or CLI; deploy pipelines for GitHub, Azure DevOps, GitLab; troubleshooting table |
| [managed-identity](managed-identity/) | Azure Managed Identity Explained: How It Works & Why Access Is Denied | a VM reading Key Vault with its identity, in Terraform and Bicep; SDK and raw-token scripts; a checkpoint script for "access denied" |
| [cicd-pipeline](cicd-pipeline/) | How CI/CD Actually Works — Without Naming a Single Tool | one build-once, promote-everywhere pipeline on GitHub, Azure DevOps and GitLab, with a tiny app to run it on |

## Shorts (under a minute): one idea, one small folder

| Folder | Short | Terraform | Bicep | Pipelines / other |
|---|---|:-:|:-:|---|
| [pin-dependencies](pin-dependencies/) | Pin What Your Pipeline Runs | ✓ | ✓ | GitHub · Azure DevOps · GitLab |
| [drift-detection](drift-detection/) | What Is Infrastructure Drift? | ✓ | ✓ | GitHub · Azure DevOps · GitLab |
| [import-existing](import-existing/) | Built in the Azure Portal? Import It, Don't Rebuild It | ✓ | ✓ | |
| [tag-inheritance](tag-inheritance/) | Tagged the Resource Group? Your Costs Are Still Untagged | ✓ | ✓ | CLI |
| [deployment-slots](deployment-slots/) | Blue-Green vs Canary Deployments | ✓ | ✓ | release scripts |
| [availability-zones](availability-zones/) | One Azure Datacenter Fails. Does Your App? | ✓ | ✓ | |
| [hub-spoke-peering](hub-spoke-peering/) | Why A Can't Reach C in Azure (Peering Isn't Transitive) | ✓ | ✓ | |
| [archive-tier](archive-tier/) | Your Cheapest Backup Might Take 15 Hours to Restore | ✓ | ✓ | rehydrate script |
| [resource-locks](resource-locks/) | Why Azure Won't Let Even the Owner Delete This | ✓ | ✓ | CLI |
| [resource-group-lifecycle](resource-group-lifecycle/) | Delete One Azure Resource Group, Lose Everything In It | ✓ | ✓ | check script |
| [vm-deallocate](vm-deallocate/) | Your Azure VM Is Off. Why Are You Still Paying? | ✓ | ✓ | find script |
| [leaked-secret](leaked-secret/) | Deleted the API Key From GitHub? It's Still There | | | push protection on all three |
| [retry-backoff](retry-backoff/) | Why Instant Retries Can Take Your Service Down | | | Python |
| [artifact-attestations](artifact-attestations/) | What GitHub Artifact Attestations Actually Prove | | | GitHub attest + verify · GitLab cosign · Azure DevOps cosign + Key Vault |
| [appgw-502-probe](appgw-502-probe/) | The App Works. Why Does Application Gateway Return 502? | ✓ | ✓ | local fixture, diagnose script |
| [topology-spread](topology-spread/) | Kubernetes Pod Pending: When Two Spread Rules Disagree | | | Kubernetes YAML, kind repro |
| [focus-reconciliation](focus-reconciliation/) | Your Cloud Usage Table Is Not Your Invoice | | | Python, SQL, sample FOCUS data |
| [oidc-deploy](oidc-deploy/) | GitHub Actions to Azure with OIDC: Trust Is Not Permission | ✓ | ✓ | GitHub · Azure DevOps · GitLab |

## Before you run anything

- These are examples: names like `rg-app-prod` and `my-org/my-app` are placeholders. Read a script before you run
  it. Scripts that change something say so at the top, and most do a dry run or a what-if first.
- Pipeline files sit inside each folder (for example `drift-detection/github/.github/workflows/`), so nothing in this
  repository runs on its own. Copy them into your repository.
- Nothing here uses a stored cloud secret. Pipelines sign in with OIDC / workload identity federation, see
  [oidc-deploy](oidc-deploy/).
- GitHub actions are pinned to commit SHAs and providers and modules to versions, see
  [pin-dependencies](pin-dependencies/). Update them before you copy.

Every example is checked with `terraform validate` (Terraform 1.16, azurerm 5.x), `bicep build` (0.48), shellcheck and
actionlint. Azure CLI commands need a recent `az` (deployment stacks need 2.61 or later).

## License

[MIT](LICENSE). Use it, change it, no warranty.
