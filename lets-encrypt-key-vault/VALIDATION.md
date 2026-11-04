# Validation (2026-11-02)

Files: `vm/issue.sh`, `vm/install-deploy-hook.sh`, `vm/check-renewal.sh`, `keyvault/policy.json`,
`keyvault/renew.sh`, `keyvault/auth-hook.sh`, `keyvault/cleanup-hook.sh`, `keyvault/azure.ini.example`,
`keyvault/README.md` (three ways to call renew.sh).

```
bash -n <each .sh>                         # OK (bash 5); shellcheck is not installed in the build box
python3 -c "import json; json.load(open('keyvault/policy.json'))"   # OK
# the GitLab job in keyvault/README.md parses with PyYAML 6 (yaml.safe_load): OK
```

**Nothing was run** against a VM, Let's Encrypt (staging or production), Azure Key Vault or Azure DNS:
certbot and the Azure CLI are not installed in the build container. Names (shop.pinecone-gear.example,
*.pinecone-gear.example, kv-pinecone, wildcard, rg-dns, /var/www/shop) are fictional.

Copied from the docs (fetched 2 Nov 2026)
- certbot.eff.org (Nginx, snap): `sudo snap install --classic certbot`, `sudo ln -s /snap/bin/certbot /usr/local/bin/certbot`,
  `sudo certbot renew --dry-run`, timer locations (`/etc/crontab/`, `/etc/cron.*/*`, `systemctl list-timers`).
- certbot User Guide 5.9.0: `certonly --webroot -w ... -d ...`; `--dry-run` (staging server, deploy hooks skipped unless
  `--run-deploy-hooks`); `/etc/letsencrypt/renewal-hooks/deploy`; the `sh -c 'printf ...'` + `chmod 755` hook pattern
  (HAProxy example); `certbot certificates`; `--csr` ("DER or PEM", "only works with the 'certonly' subcommand");
  `--cert-path`, `--chain-path`, `--fullchain-path`; `--manual`, `--preferred-challenges`, `--manual-auth-hook`,
  `--manual-cleanup-hook`, `CERTBOT_VALIDATION`, `CERTBOT_DOMAIN`; `--config-dir`, `--work-dir`, `--logs-dir`,
  `--server`, `-n`, `--agree-tos`, `-m`.
- Azure CLI reference: `az login --identity` (+ `--client-id`); `az keyvault certificate create -p @file`,
  `show`, `pending show`, `pending merge --file --name --vault-name`, `pending delete`;
  `az network dns record-set txt add-record / remove-record -g -z -n -v`, `--keep-empty-record-set`.
- Key Vault "Unknown" issuer for a manually completed certificate, and the pending operation's `csr` field (base64):
  "Certificate creation methods" and "Monitor and manage certificate creation" (REST examples).

Not verified, check before relying on it
- `--query csr` on `az keyvault certificate pending show`: the CLI page doesn't show the output shape; the REST response
  has a `csr` field (base64 DER, no PEM header), so the script base64-decodes it into a DER file (certbot accepts DER).
- `policy.json` field names follow the Key Vault REST/CLI policy shape (`issuerParameters`, `keyProperties`,
  `x509CertificateProperties`, `lifetimeActions`); compare with `az keyvault certificate get-default-policy --scaffold`.
  `exportable: true` is assumed to be needed for App Service / Application Gateway to read the PFX.
- That `az keyvault certificate create` on an existing name creates a NEW VERSION (the portal's "New Version" does; Learn's
  CLI tab for renewal didn't load).
- `attributes.expires` as the JMESPath for the expiry in `az keyvault certificate show`.
- Whether `pending merge` accepts certbot's fullchain PEM (leaf + intermediate) as is. Learn: merge supports
  `-----BEGIN CERTIFICATE-----` PEM and base64 P7B chains; the CLI says "certificate or certificate chain".
- The `sleep` after adding the TXT record: Let's Encrypt's docs say to wait for propagation; the 60 s default is a guess.
- A role assignment scoped to the record set needs that record set to exist first; create `_acme-challenge` once
  (and the cleanup hook keeps it, with `--keep-empty-record-set`).
- Certificate contacts for the near-expiry email (`EmailContacts`) must be set on the vault; the CLI syntax for contacts
  wasn't checked.
- `systemctl reload nginx` and the nginx `ssl_certificate` lines are standard systemd/nginx syntax, not from certbot docs.

Added 2 Nov 2026 (one idempotent renew.sh, event/timer/pipeline callers, community DNS plugin, CNAME delegation)
- Verified: GitLab `id_tokens` + `aud`, and `az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID
  --federated-token $GITLAB_OIDC_TOKEN` (GitLab docs, "Configure OpenID Connect in Azure"); `--federated-token`
  ("Federated token that can be used for OIDC token exchange") in the Azure CLI `az login` reference; Let's Encrypt:
  "you can use CNAME records or NS records to delegate answering the challenge to other DNS zones".
- certbot-dns-azure: PyPI shows 2.6.1 (4 Dec 2024), maintainer Terri Cain, Apache 2.0; not in certbot's official DNS
  plugin list (listed as third-party). Options `--authenticator dns-azure --preferred-challenges dns --dns-azure-config`
  and the `dns_azure_zone1 = <zone>:/subscriptions/<id>/resourceGroups/<rg>` / `dns_azure_environment` keys are from the
  plugin's Docker README on GitHub. Its documentation site could not be fetched.
- NOT verified: `dns_azure_use_cli_credentials = true` (taken from a colleague's working pipeline, not read in the plugin
  docs), whether the plugin follows a CNAME-delegated `_acme-challenge` and which zone to list in `dns_azure_zone1` for it,
  and whether `pip install azure-cli` in python:3.13-slim is the supported way to get the CLI (the GitLab example uses the
  mcr.microsoft.com/azure-cli image instead).
- Verified: `Microsoft.KeyVault.CertificateNearExpiry` is "triggered 30 days before the expiration date" (Event Grid
  Key Vault schema, 26 Mar 2026); the reference architecture's event → Automation webhook runbook → CSR → CA → merge flow.
  NOT verified/tested: running a bash script from an Automation runbook / Hybrid Runbook Worker (no runbook code shipped);
  the cron line is standard cron.d syntax.
- The 30-day threshold for 45/47-day certificates (day ~15-17) is our arithmetic.
- The GitLab job keeps no artifacts and no cache. Without a persisted config dir, certbot registers an ACME account on each run
  that actually renews (the expiry check skips the rest). To reuse one account, persist `--config-dir` somewhere
  protected (it holds the account key), not as a job artifact.
- The simpler variant (certbot makes the key; `openssl pkcs12` then `az keyvault certificate import`) is only mentioned
  in the video. No code for it, and openssl syntax wasn't checked. Key Vault also imports a PEM file with the
  certificate and an unencrypted PKCS#8 key (Learn).
