# Find the Fault #1: the conditional forwarder (Cloud Signal). Pinecone names are fictional.
# Not run against a live server: the cmdlets and parameters are from the DnsServer module docs.
#
# Run on Pinecone's Windows DNS server: dns-01, 10.20.0.4, in vnet-pinecone-hub (an Azure VM).
# vnet-pinecone-hub must be linked to the private DNS zone privatelink.database.windows.net (main.bicep / main.tf):
# Azure DNS only answers from a private zone for queries that come from a linked virtual network.
#
# Forward the PUBLIC zone (database.windows.net), not privatelink.database.windows.net.
# DNS server on-premises instead? Forward database.windows.net to a DNS forwarder or to the
# Azure DNS Private Resolver inbound endpoint in Azure, not to 168.63.129.16.

# 1. Conditional forwarder: database.windows.net -> Azure DNS (168.63.129.16), stored on this server
Add-DnsServerConditionalForwarderZone -Name "database.windows.net" -MasterServers 168.63.129.16 -PassThru

# Using a Private Resolver instead? Use its inbound endpoint IP (output resolverInboundIp / resolver_inbound_ip):
# Add-DnsServerConditionalForwarderZone -Name "database.windows.net" -MasterServers <inbound-endpoint-ip> -PassThru

# 2. Drop the public answer this server has cached
Clear-DnsServerCache -Force

# 3. On the app VM (vm-shop-app), clear the client cache and test again:
#    ipconfig /flushdns
#    nslookup pinecone-sql.database.windows.net                  # expected: 10.30.2.5 via 10.20.0.4
#    Test-NetConnection pinecone-sql.database.windows.net -Port 1433   # RemoteAddress 10.30.2.5
# Keep the connection string on pinecone-sql.database.windows.net: logins to the private IP or to the
# privatelink name fail by design (Microsoft Learn, Azure Private Link for Azure SQL Database).
