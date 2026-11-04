# Key Vault-first renewal with Let's Encrypt

`renew.sh` is the whole automation. It is idempotent: it reads the Key Vault certificate's expiry and exits when renewal
isn't due. When it is due it runs the chain: new version with issuer "Unknown" (Key Vault generates the key pair + CSR) →
`certbot certonly --csr` with DNS-01 (community plugin certbot-dns-azure, or `AUTH_MODE=hooks` for the two Azure CLI hooks)
→ `az keyvault certificate pending merge`. The private key never leaves Key Vault. Not run against Azure or Let's Encrypt:
see ../VALIDATION.md.

Files: `renew.sh`, `policy.json`, `azure.ini.example` (plugin config, no secret), `auth-hook.sh` / `cleanup-hook.sh`
(no-plugin alternative).

Identity it runs as: Key Vault Certificates Officer on the vault; DNS rights only on a small challenge-only zone (narrowest: DNS Zone Contributor scoped to the one delegated TXT record set, created once with value "-")
(`_acme-challenge.<domain>` is a CNAME into it). Sign-in: managed identity (`az login --identity`) or OIDC / workload
identity federation (no stored secret).

Start with `ACME_SERVER` = the staging directory (the default in the script); switch to production once a full run works.
Keep certbot's config directory between runs if you can (one ACME account); otherwise the expiry check keeps
registrations to the runs that actually renew. Never issue on a daily schedule (production: 5 certificates per exact
set of names per 7 days).

## Three ways to call it

### 1. When needed: Key Vault near-expiry event (Microsoft's pattern)
Key Vault publishes `Microsoft.KeyVault.CertificateNearExpiry` to Event Grid 30 days before the expiration date.
Microsoft's "Certificate life cycle management on Azure" architecture subscribes to it with an Automation webhook
(plus a storage queue for retries) and runs the CSR → CA → merge script on a Hybrid Runbook Worker. Same idea here:
the runbook runs `renew.sh` on a worker that has certbot and the Azure CLI. (Runbook code not included; not tested.)

### 2. Simple fallback / safety net: a timer on a VM
```
# /etc/cron.d/keyvault-renew  (weekly, Monday 03:17; the script exits if not due)
17 3 * * 1  root  KV=kv-pinecone CERT=wildcard ACME_EMAIL=ops@pinecone-gear.example /opt/keyvault/renew.sh
```

### 3. A pipeline schedule (GitLab shown; Azure DevOps / GitHub Actions work the same way)
```yaml
renew-keyvault-wildcard:
  image: python:3.13-slim
  rules:
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.com
  before_script:
    - apt-get update && apt-get install -y --no-install-recommends ca-certificates openssl && pip install --no-cache-dir certbot certbot-dns-azure-modern azure-cli
    - cp code/keyvault/azure.ini.example code/keyvault/azure.ini && chmod 400 code/keyvault/azure.ini
  script:
    - az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token $GITLAB_OIDC_TOKEN
    - bash code/keyvault/renew.sh
  # no artifacts, no cache: no certificate or key files leave the job
```
Variables: `KV`, `CERT`, `ACME_EMAIL`, `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` (CI/CD variables). Federated credential
subject (GitLab docs): `project_path:<group>/<project>:ref_type:branch:ref:main`; its audience must match `aud`.
