# Stop the bleeding (week one, while you decide)

None of this needs the target architecture. It makes sure you still have an estate when you are ready to fix it.

| Do | Terraform | Bicep | CLI |
|---|---|---|---|
| Delete locks on production resource groups | [`terraform/main.tf`](terraform/main.tf) | [`bicep/locks.bicep`](bicep/locks.bicep) | [`lock-production.sh`](lock-production.sh) (dry run, then `--apply`) |
| Monthly budget with alerts, per subscription | [`terraform/main.tf`](terraform/main.tf) | [`bicep/budget.bicep`](bicep/budget.bicep) | |

And two things no template does for you:

- **Prove backups restore**: restore one VM or database into a test resource group. A backup you never restored is
  a hope.
- **Two emergency access (break-glass) accounts**: cloud-only, not dependent on one person's phone or on the old
  team, strong phishing-resistant credentials stored safely, every sign-in alerted. Follow
  [Microsoft's guidance](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access).

Locks are not access control: anyone with `Microsoft.Authorization/locks/delete` can remove one. They stop the
accidental click, not a determined admin. See [resource-locks](../../resource-locks/).
