# Managed identity: how it works, and why access is still denied

Companion code for the Cloud Signal explainer **"Azure Managed Identity Explained: How It Works & Why Access Is
Denied"**.

A managed identity removes the stored credential, not the rest of the chain. A VM reading a Key Vault secret needs
every checkpoint to pass:

| Checkpoint | What can go wrong | Check |
|---|---|---|
| 1. Identity exists | not enabled, or the app asks for a user-assigned one by the wrong client ID | `check.sh` step 1 |
| 2. Token for the right audience | token requested for `management.azure.com` instead of `vault.azure.net` | [`app/imds-token.sh`](app/imds-token.sh) prints `aud` |
| 3. Network | vault firewall denies the VM's subnet, private endpoint without private DNS | `check.sh` step 2 |
| 4. Authorization | no data-plane role (`Key Vault Secrets User`), wrong scope, or access policies vs. RBAC mode mixed up | `check.sh` steps 3-4 |
| 5. Propagation | role just assigned, token issued before it | wait a few minutes, get a new token |

A valid token from a real identity can still be denied: authentication said *who*, authorization says *what*.

## Build the example

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) |

Both create a Key Vault in RBAC mode with one secret, a Linux VM with a system-assigned identity, and the
`Key Vault Secrets User` role for that identity on the vault (nothing broader).

```bash
# Terraform (if the secret fails on the first apply, your own role is still propagating: apply again)
terraform -chdir=terraform apply -var name=demo42 -var "ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)"

# Bicep
az group create -n rg-mi -l westeurope
az deployment group create -g rg-mi -f bicep/main.bicep -p name=demo42 \
  sshPublicKey="$(cat ~/.ssh/id_ed25519.pub)" deployerObjectId="$(az ad signed-in-user show --query id -o tsv)"
```

Then on the VM (connect with Bastion or `az ssh vm`): [`app/get_secret.py`](app/get_secret.py) reads the secret with
`ManagedIdentityCredential` and explains which checkpoint failed if it doesn't work. To see it fail on purpose,
remove the role assignment and run it again.

## System-assigned or user-assigned?

| | System-assigned | User-assigned |
|---|---|---|
| Lifecycle | created and deleted with the resource | its own resource, survives the VM |
| Shared | one resource only | can be attached to many resources |
| Good for | one app, one VM | scale sets, blue-green swaps, pre-granting access before the VM exists |

## Sources

- Managed identities overview: https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview
- How managed identities work with Azure VMs: https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-managed-identities-work-vm
- Use a VM's managed identity to get a token: https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token
- Key Vault RBAC guide: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide
- Key Vault behind a firewall: https://learn.microsoft.com/en-us/azure/key-vault/general/access-behind-firewall
