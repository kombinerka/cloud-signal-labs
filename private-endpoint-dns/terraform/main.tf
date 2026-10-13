# Storage account reachable only through a private endpoint, WITH the private DNS that makes the normal name
# (mystore.blob.core.windows.net) resolve to the private IP inside the virtual network.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "name" {
  description = "Globally unique storage account name"
  type        = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azurerm_resource_group" "pe" {
  name     = "rg-pe-demo"
  location = var.location
}

resource "azurerm_virtual_network" "pe" {
  name                = "vnet-pe-demo"
  location            = azurerm_resource_group.pe.location
  resource_group_name = azurerm_resource_group.pe.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "pe" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.pe.name
  virtual_network_name = azurerm_virtual_network.pe.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_storage_account" "st" {
  name                     = var.name
  resource_group_name      = azurerm_resource_group.pe.name
  location                 = azurerm_resource_group.pe.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  public_network_access    = "Disabled" # only the private path is left
  min_tls_version          = "TLS1_2"
}

# 1. The private DNS zone for this service (Blob). Other services use other zones (vaultcore, database, ...).
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.pe.name
}

# 2. Link it to the virtual network, so resolvers in that network use it.
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                = "link-vnet-pe-demo"
  private_dns_zone_id = azurerm_private_dns_zone.blob.id
  virtual_network_id  = azurerm_virtual_network.pe.id
}

# 3. The endpoint, with a DNS zone group: it registers (and later removes) its A record in the zone.
resource "azurerm_private_endpoint" "blob" {
  name                = "pe-${var.name}-blob"
  location            = azurerm_resource_group.pe.location
  resource_group_name = azurerm_resource_group.pe.name
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "blob"
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}
