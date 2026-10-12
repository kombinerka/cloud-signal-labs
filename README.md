# Cloud Signal Labs

Working examples for the videos on the **Cloud Signal** YouTube channel: Azure, DevOps, DevSecOps and FinOps,
explained in practice.

Every folder belongs to one video, has its own README, and can be used on its own. Where infrastructure code comes up,
you get **both Terraform and Bicep**. Where a pipeline comes up, you get **GitHub Actions, Azure Pipelines and GitLab
CI**. Use the one your team runs.

## Folders

| Folder | Video | Terraform | Bicep | Pipelines |
|---|---|:-:|:-:|---|
| [azure-takeover](azure-takeover/) | You Inherited a Messy Azure Setup. Don't Start With Terraform. | ✓ | ✓ | GitHub · Azure DevOps · GitLab |
| [oidc-deploy](oidc-deploy/) | Deploy to Azure Without a Stored Secret | ✓ | ✓ | GitHub · Azure DevOps · GitLab |
| [pin-dependencies](pin-dependencies/) | Pin What Your Pipeline Runs | ✓ | ✓ | GitHub · Azure DevOps · GitLab |
| [drift-detection](drift-detection/) | What Is Infrastructure Drift? | ✓ | ✓ | GitHub · Azure DevOps · GitLab |
| [import-existing](import-existing/) | Built in the Azure Portal? Import It, Don't Rebuild It | ✓ | ✓ | |
| [tag-inheritance](tag-inheritance/) | Tagged the Resource Group? Your Azure Costs Are Still Untagged | ✓ | ✓ | |
| [deployment-slots](deployment-slots/) | Blue-Green vs Canary Deployments | ✓ | ✓ | |
| [resource-locks](resource-locks/) | Why Azure Won't Let Even the Owner Delete This | ✓ | ✓ | |
| [vm-deallocate](vm-deallocate/) | Your Azure VM Is Off. Why Are You Still Paying? | ✓ | ✓ | |
| [leaked-secret](leaked-secret/) | Deleted the API Key From GitHub? It's Still There | | | push protection on all three |
| [retry-backoff](retry-backoff/) | Why Instant Retries Can Take Your Service Down | | | |

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
