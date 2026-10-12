# Pushed a secret? Rotate first, then clean up

Companion code for the Cloud Signal Short **"Deleted the API Key From GitHub? It's Still There"**.

Deleting the file in a new commit doesn't remove it: every earlier commit, every clone and every fork still has it.
Even rewriting history doesn't reach copies other people already have. Treat a pushed secret as a leaked secret.

1. **Revoke and replace the secret.** At the provider (Azure portal, the API vendor), not in Git. Update whatever
   uses it. Check its sign-in or usage logs for use you don't recognise.
2. **Remove it from history**: [`remove-from-history.sh`](remove-from-history.sh) (git filter-repo on a mirror
   clone, then a force-push). Optional once the secret is dead, but it keeps scanners and future readers quiet.
3. **Block the next one before it lands**: push protection.

## Push protection on each platform

| Platform | Feature | Turn it on |
|---|---|---|
| GitHub | Secret scanning push protection (free for public repos; GitHub Secret Protection for private) | Settings → Advanced Security, or `gh api -X PATCH repos/OWNER/REPO -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'` |
| GitLab | Secret push protection (Ultimate) | Secure → Security configuration → Secret push protection |
| Azure DevOps | GitHub Advanced Security for Azure DevOps: push protection | Repository settings → Advanced Security |
| Any Git host | a pre-commit hook, e.g. [gitleaks](https://github.com/gitleaks/gitleaks) | [`.pre-commit-config.yaml`](.pre-commit-config.yaml) |

## Keep secrets out of code in the first place

- Infrastructure code: reference Key Vault instead of passing values (Bicep `getSecret()`, Terraform
  `azurerm_key_vault_secret` data source), and mark outputs and variables as secure/sensitive.
- Pipelines: no stored cloud credentials at all, see [oidc-deploy](../oidc-deploy/).

## Sources

- GitHub Docs: Removing sensitive data from a repository: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
- GitHub Docs: Push protection: https://docs.github.com/en/code-security/secret-scanning/introduction/about-push-protection
- GitLab Docs: Secret push protection: https://docs.gitlab.com/user/application_security/secret_detection/secret_push_protection/
- git filter-repo: https://github.com/newren/git-filter-repo
