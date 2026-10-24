# Validation (2026-10-16)

Files: `main.bicep`, `main.tf`, `versions.tf`, `forwarder.ps1`.

```
bicep build main.bicep --stdout >/dev/null        # Bicep CLI 0.48.1: OK, no warnings
terraform fmt -check                              # OK
# in a temp copy of the folder:
terraform init -backend=false && terraform validate   # Terraform 1.9.8, hashicorp/azurerm 4.81.0: "The configuration is valid."
```

`forwarder.ps1` was not run (no Windows DNS server here, no PowerShell in the build box). Its cmdlets and parameters
were checked against the DnsServer module docs: `Add-DnsServerConditionalForwarderZone -Name -MasterServers -PassThru`
(file-backed forwarder, stored on that server) and `Clear-DnsServerCache -Force`.

Not deployed or run against a live subscription. Names (pinecone-sql, vnet-pinecone-hub, vnet-pinecone-shop,
pe-pinecone-sql, dns-01, dnspr-pinecone-hub) and addresses are fictional.

Notes
- The zone name is hard-coded for Azure public cloud (`privatelink.database.windows.net`); the Bicep linter rule
  `no-hardcoded-env-urls` is disabled for that one line on purpose, so the file matches the zone name in the docs.
- Both VNets get a resolution link (`registrationEnabled: false` / `registration_enabled = false`). The hub link matters:
  the custom DNS server forwards to Azure DNS from the hub, and Azure DNS answers from a private zone only for queries
  from a linked VNet.
- The private endpoint is declared with its DNS zone group. If Pinecone's endpoint already exists, import it first
  (Terraform `import` block / `terraform import`; Bicep deploys in place under the same name), or the Terraform plan
  creates a second endpoint.
- The Private Resolver is optional (`deployPrivateResolver` / `deploy_private_resolver`, default false). It needs a
  dedicated hub subnet delegated to `Microsoft.Network/dnsResolvers`; the DNS server then forwards
  `database.windows.net` to the inbound endpoint IP (output `resolverInboundIp` / `resolver_inbound_ip`).
