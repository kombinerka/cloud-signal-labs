# Pin what your pipeline runs

▶ **[Watch the video](https://www.youtube.com/watch?v=hA9oGWA1OY0)**

Companion code for the Cloud Signal Short **"Pin What Your Pipeline Runs: GitHub, GitLab and Azure DevOps"**.

Your pipeline runs code you didn't write: actions, included templates, Marketplace tasks, container images.
Most of it is referenced by a label that can move (a tag like `v4`, a branch, `latest`). In March 2025 the tags of
`tj-actions/changed-files` were moved to a malicious commit that printed CI secrets into build logs
([CVE-2025-30066](https://www.cisa.gov/news-events/alerts/2025/03/18/supply-chain-compromise-third-party-github-action-cve-2025-30066)).
Every workflow that used `@v35` or `@v45` ran the new code on its next run.

| CI platform | What to pin | File |
|---|---|---|
| GitHub Actions | every `uses:` to a full 40-character commit SHA, keep the version in a comment, let Dependabot update it | [`github/.github/workflows/build.yml`](github/.github/workflows/build.yml), [`dependabot.yml`](github/.github/dependabot.yml) |
| GitLab CI | `include: project:` with the full commit SHA as `ref`; CI/CD components to an exact version | [`gitlab/.gitlab-ci.yml`](gitlab/.gitlab-ci.yml) |
| Azure Pipelines | Marketplace and built-in tasks to the full `major.minor.patch` version (tasks can't be pinned to a commit); only allow extensions from trusted publishers | [`azure-devops/azure-pipelines.yml`](azure-devops/azure-pipelines.yml) |
| Container images (all three) | the image digest (`@sha256:...`), not the tag | all three files |

The same applies to the infrastructure code itself:

| IaC | What to pin | File |
|---|---|---|
| Terraform | `required_version`, provider versions, and commit `.terraform.lock.hcl` (exact provider build + checksums); registry modules to an exact `version`, Git modules to a commit SHA | [`iac/terraform/versions.tf`](iac/terraform/versions.tf) |
| Bicep | registry modules (`br:` / `br/public:avm/...`) to an exact version tag; an explicit API version on every resource | [`iac/bicep/main.bicep`](iac/bicep/main.bicep) |

## Find what is still unpinned

```bash
./find-unpinned.sh path/to/repo
```

It lists GitHub `uses:` lines that aren't a commit SHA, GitLab `include` refs that aren't a SHA, Azure Pipelines tasks
pinned only to a major version, and images without a digest. It only reads files.

## Getting the values

```bash
# GitHub action: the commit behind a tag (use the ^{} line for annotated tags)
git ls-remote https://github.com/actions/checkout 'refs/tags/v7.0.1' 'refs/tags/v7.0.1^{}'

# Container image digest
docker buildx imagetools inspect mcr.microsoft.com/azure-cli:latest --format '{{json .Manifest.Digest}}'

# Azure Pipelines: the full task version is printed at the top of the task's log in any run
#   Task         : Azure CLI
#   Version      : 2.x.y
```

## Notes

- A pinned SHA doesn't update itself. That is the point, but you still need updates: Dependabot (GitHub) or
  Renovate (GitHub, GitLab, Azure DevOps) open a pull request when a new version is released, so a person reviews
  every change.
- GitHub can enforce SHA pinning for a repository or organization (Settings → Actions → "Require actions to be pinned
  to a full-length commit SHA").
- Azure DevOps: Organization settings → Extensions controls who can install Marketplace extensions. Prefer
  built-in tasks or a reviewed script over a third-party task for anything that touches secrets.

## Sources

- GitHub Docs, Secure use reference: https://docs.github.com/en/actions/reference/security/secure-use
- GitLab Docs, CI/CD YAML syntax (`include:project`, components): https://docs.gitlab.com/ci/yaml/
- Azure DevOps Docs, task versions: https://learn.microsoft.com/en-us/azure/devops/pipelines/process/tasks
- Microsoft Zero Trust workshop, DevSecOps DS_032: https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devsecops/DS_032
