# Catch infrastructure drift with a scheduled check

Companion code for the Cloud Signal Short **"What Is Infrastructure Drift? (In 40 Seconds)"**.

Your code says the network security group only allows 443. At 2 AM someone opened 22 in the portal and never closed
it. Reviews still pass, because the code still looks right. The risk only exists in the portal.

Both tools can compare the real resources with the code. Run the check on a schedule and fail loudly on a difference:

| | Terraform | Bicep |
|---|---|---|
| Example | [`terraform/main.tf`](terraform/main.tf) | [`bicep/main.bicep`](bicep/main.bicep) |
| Check | [`terraform/drift-check.sh`](terraform/drift-check.sh): `terraform plan -detailed-exitcode` | [`bicep/drift-check.sh`](bicep/drift-check.sh): `az deployment group what-if`, noise filtered |
| Exit codes | 0 no differences, 1 error, 2 differences | same (the script maps what-if to them) |
| Compares with | state + real resources | real resources only (no state) |
| Prevent instead of detect | Azure Policy, no portal write access | deployment stacks with deny settings (see [azure-takeover](../azure-takeover/05-deployment-stacks/)) |

The pipelines run either one; set `TOOL` to `terraform` or `bicep`:

| Platform | File | Signs in with |
|---|---|---|
| GitHub Actions | [`github/.github/workflows/drift.yml`](github/.github/workflows/drift.yml) | OIDC, no secret ([oidc-deploy](../oidc-deploy/)) |
| Azure Pipelines | [`azure-devops/drift.yml`](azure-devops/drift.yml) | service connection with workload identity federation |
| GitLab CI | [`gitlab/.gitlab-ci.yml`](gitlab/.gitlab-ci.yml) + a pipeline schedule | GitLab ID token, no secret |

The identity only needs **Reader** on the resources (plus Storage Blob Data Reader on the Terraform state container).
`-lock=false` is safe because the job never applies.

Declare the NSG rules **inline** (both examples do). Then a port-22 rule added in the portal is a difference in the
NSG itself. With separate rule resources, Terraform only sees the rules it manages, and an extra hand-made rule
stays invisible.

## When it finds drift

You decide, per difference:

- **Keep it**: the manual change was right. Put it into code, open a pull request, apply.
- **Revert it**: the next deployment (`terraform apply`, or redeploying the Bicep) puts the resource back to what the code says.

Then make the next one less likely: remove write access in the portal for people (deploy through the pipeline
identity), and use Azure Policy for the rules that must always hold (for example, deny NSG rules that open 22 to the
internet).

## Notes

- Terraform: a normal plan also reports code that was merged but never applied. For changes made in Azure only, use
  `terraform plan -refresh-only -detailed-exitcode` (real resources vs. state, code ignored).
- Bicep what-if can report changes that aren't real, especially for properties Azure fills in and references to
  existing resources. The script ignores `NoChange` and `Ignore`; if a property is always reported, review it once
  and filter it out explicitly rather than ignoring the whole resource.

## Sources

- Terraform CLI: plan, `-detailed-exitcode`, `-refresh-only`: https://developer.hashicorp.com/terraform/cli/commands/plan
- Azure: deployment what-if: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-what-if
- azurerm provider: authenticating with OIDC: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc
