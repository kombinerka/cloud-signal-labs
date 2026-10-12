# Option 2: Bicep with deployment stacks

A deployment stack is a group of resources Azure tracks as one unit, so Azure is the system of record, not a state
file. Deny settings stop changes outside the stack, Owners included.

| File | What |
|---|---|
| [`main.bicep`](main.bicep) | a small workload (VNet with inline subnets, locked-down storage) |
| [`deploy-stack.sh`](deploy-stack.sh) | `az stack group create` with `--deny-settings-mode denyWriteAndDelete`, a break-glass group excluded, `--action-on-unmanage detachAll` |
| [`ps-rule.yaml`](ps-rule.yaml) | PSRule for Azure: Well-Architected rules as tests for every change |
| [`pipelines/github/stack.yml`](pipelines/github/stack.yml) | GitHub Actions: PSRule on pull requests, deploy on main (OIDC) |
| [`pipelines/azure-devops/stack.yml`](pipelines/azure-devops/stack.yml) | Azure Pipelines: same, with a workload identity service connection |
| [`pipelines/gitlab/.gitlab-ci.yml`](pipelines/gitlab/.gitlab-ci.yml) | GitLab CI: same, with a GitLab ID token |

`--action-on-unmanage`: when you remove a resource from the template, `detachAll` lets go of it (default and the
safe choice during a takeover); `deleteResources` / `deleteAll` delete it.

The same three habits work with Terraform too: a validated pattern library, tests in the pipeline (PSRule, Checkov,
tflint), and policy as code (EPAC). Terraform option: [`../04-terraform-loop/`](../04-terraform-loop/).
