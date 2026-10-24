# Azure Private Endpoint DNS Troubleshooting: Why the VM Gets the Public IP

▶ **[Watch the video](https://www.youtube.com/watch?v=V8NzanEmzt8)**

Companion to the Cloud Signal video (Find the Fault #1). A private endpoint was added to Azure SQL, but the VM still
resolves the public IP: the custom DNS server has no forwarder for `database.windows.net`.

The three checks, in order:
1. The private DNS zone (`privatelink.database.windows.net`) exists, with an A record for your resource.
2. The zone is linked to the virtual network that asks Azure DNS: your DNS server's or resolver's network, not only the client's.
3. Your custom DNS server forwards `database.windows.net` to Azure DNS (168.63.129.16) or to a Private Resolver inbound endpoint.

| File | What it is |
|---|---|
| `main.bicep` | private endpoint, private DNS zone, A record, VNet links (Bicep) |
| `main.tf`, `versions.tf` | the same in Terraform (azurerm) |
| `forwarder.ps1` | conditional forwarder on a Windows DNS server + cache flush |
| `VALIDATION.md` | how it was checked |

Validated (bicep build, terraform validate), **not deployed**. Names and addresses are fictional (Pinecone).
