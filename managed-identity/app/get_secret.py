"""Run ON the VM: read a Key Vault secret with the VM's managed identity. No credential in code or config.
    pip install azure-identity azure-keyvault-secrets
    VAULT_URL=https://kv-mi-<name>.vault.azure.net/ python3 get_secret.py
"""
import os

from azure.core.exceptions import ClientAuthenticationError, HttpResponseError
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

# ManagedIdentityCredential, not DefaultAzureCredential: on a server you want exactly one credential source,
# so a failure points at the managed identity instead of silently trying something else.
# For a user-assigned identity: ManagedIdentityCredential(client_id="<client-id>")
credential = ManagedIdentityCredential()
client = SecretClient(vault_url=os.environ["VAULT_URL"], credential=credential)

try:
    secret = client.get_secret("db-password")
    print("read secret, length", len(secret.value))
except ClientAuthenticationError as e:
    print("No token: is the identity enabled on this VM? Can the VM reach 169.254.169.254?\n", e)
except HttpResponseError as e:
    if e.status_code == 403:
        print("Token accepted, access denied: role assignment missing, wrong scope, or not propagated yet.\n", e.message)
    else:
        print("Key Vault said", e.status_code, "- check network rules / firewall / private endpoint.\n", e.message)
