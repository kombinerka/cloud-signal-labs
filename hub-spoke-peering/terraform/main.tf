# Hub and spoke: every spoke peers with the hub; spoke-to-spoke traffic goes through a firewall/NVA in the hub,
# steered there by a route table (peering is not transitive, so it never happens on its own).
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

variable "location" {
  type    = string
  default = "westeurope"
}

variable "spokes" {
  description = "Spoke name => address space"
  type        = map(string)
  default = {
    a = "10.1.0.0/24"
    c = "10.2.0.0/24"
  }
}

variable "firewall_private_ip" {
  description = "Private IP of the Azure Firewall or NVA in the hub that forwards spoke-to-spoke traffic"
  type        = string
  default     = "10.0.0.4"
}

resource "azurerm_resource_group" "net" {
  name     = "rg-hub-spoke"
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_virtual_network" "spoke" {
  for_each            = var.spokes
  name                = "vnet-spoke-${each.key}"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  address_space       = [each.value]
}

resource "azurerm_subnet" "workload" {
  for_each             = var.spokes
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.spoke[each.key].name
  address_prefixes     = [each.value]
}

# A peering is one direction; each link needs both halves.
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each                  = var.spokes
  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.net.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke[each.key].id
  allow_forwarded_traffic   = true # traffic the firewall forwards from another spoke
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                  = var.spokes
  name                      = "${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.net.name
  virtual_network_name      = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

# User-defined route: traffic for the other spokes goes to the firewall in the hub.
resource "azurerm_route_table" "spoke" {
  for_each            = var.spokes
  name                = "rt-spoke-${each.key}"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name

  dynamic "route" {
    for_each = { for k, cidr in var.spokes : k => cidr if k != each.key }
    content {
      name                   = "to-spoke-${route.key}"
      address_prefix         = route.value
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  }
}

resource "azurerm_subnet_route_table_association" "spoke" {
  for_each       = var.spokes
  subnet_id      = azurerm_subnet.workload[each.key].id
  route_table_id = azurerm_route_table.spoke[each.key].id
}

# The firewall itself (Azure Firewall or an NVA with IP forwarding) is not included here; it costs money while it
# runs. Its private IP must match var.firewall_private_ip, and it needs rules that allow the spoke-to-spoke traffic.
