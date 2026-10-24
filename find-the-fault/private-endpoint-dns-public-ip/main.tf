# Find the Fault #1: a private SQL endpoint that resolves to its public IP (Cloud Signal).
# Pinecone names are fictional. Validated with `terraform validate`, not deployed.
#
# Same design as main.bicep:
#   1. private DNS zone privatelink.database.windows.net
#   2. resolution links to the shop VNet AND the hub VNet (where the custom DNS server or resolver lives)
#   3. private endpoint for the SQL server with a private_dns_zone_group (Azure manages the A record)
#   4. optional Azure DNS Private Resolver + inbound endpoint in the hub (deploy_private_resolver = true)
# The conditional forwarder on the Windows DNS server is in forwarder.ps1.
# Already have the endpoint? Import it (terraform import / an import block) before applying, or the
# plan creates a second one.

variable "resource_group_name" {
  type        = string
  description = "Resource group for the zone, the endpoint and the resolver (e.g. rg-pinecone-network)."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Region for the private endpoint and the resolver. Private DNS zones are global."
}

variable "sql_server_id" {
  type        = string
  description = "Resource ID of the existing logical SQL server (pinecone-sql)."
}

variable "shop_vnet_id" {
  type        = string
  description = "Resource ID of vnet-pinecone-shop (app VM and private endpoint)."
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of vnet-pinecone-hub (custom DNS server or Private Resolver)."
}

variable "endpoint_subnet_id" {
  type        = string
  description = "Resource ID of the private endpoint subnet in the shop VNet."
}

variable "deploy_private_resolver" {
  type        = bool
  default     = false
  description = "true = also deploy an Azure DNS Private Resolver with an inbound endpoint in the hub VNet."
}

variable "resolver_inbound_subnet_id" {
  type        = string
  default     = null
  description = "Dedicated hub subnet delegated to Microsoft.Network/dnsResolvers (only with deploy_private_resolver)."
}

# 1. The private DNS zone (recommended name for Azure SQL Database)
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

# 2a. Link to the shop VNet
resource "azurerm_private_dns_zone_virtual_network_link" "shop" {
  name                  = "link-vnet-pinecone-shop"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.shop_vnet_id
  registration_enabled  = false
}

# 2b. Link to the hub VNet: the DNS server (or resolver) asks Azure DNS from this network
resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "link-vnet-pinecone-hub"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.hub_vnet_id
  registration_enabled  = false
}

# 3. Private endpoint with a DNS zone group
resource "azurerm_private_endpoint" "sql" {
  name                = "pe-pinecone-sql"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id

  private_service_connection {
    name                           = "pinecone-sql"
    private_connection_resource_id = var.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }
}

# 4. Optional: Azure DNS Private Resolver with an inbound endpoint in the hub.
#    The DNS server (or an on-premises one) then forwards database.windows.net to the inbound endpoint IP.
resource "azurerm_private_dns_resolver" "hub" {
  count               = var.deploy_private_resolver ? 1 : 0
  name                = "dnspr-pinecone-hub"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.hub_vnet_id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "hub" {
  count                   = var.deploy_private_resolver ? 1 : 0
  name                    = "inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub[0].id
  location                = var.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = var.resolver_inbound_subnet_id
  }
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.sql.id
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.sql.private_service_connection[0].private_ip_address
}

output "resolver_inbound_ip" {
  value = var.deploy_private_resolver ? azurerm_private_dns_resolver_inbound_endpoint.hub[0].ip_configurations[0].private_ip_address : null
}
