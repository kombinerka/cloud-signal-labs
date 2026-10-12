# A minimal landing zone to learn from: management groups, subscription placement, two inherited policies and a hub
# network. For a real platform use the Azure Landing Zones accelerator (see ../README.md).
#   terraform apply -var-file=example.tfvars
# Needs: Management Group Contributor at the tenant root group (or the parent you choose), Owner on the
# subscriptions you place, and Network Contributor in the connectivity subscription.
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

# The hub lives in the Connectivity subscription.
provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivity_subscription_id
  features {}
}

variable "prefix" {
  description = "Short name for the organisation, used in management group IDs"
  type        = string
  default     = "orchard"
}

variable "allowed_locations" {
  type    = list(string)
  default = ["westeurope", "northeurope"]
}

variable "connectivity_subscription_id" {
  type = string
}

variable "management_subscription_id" {
  type = string
}

variable "corp_subscription_ids" {
  description = "Workload subscriptions that connect to the corporate network (e.g. Orchard production)"
  type        = list(string)
  default     = []
}

variable "hub_address_space" {
  type    = string
  default = "10.0.0.0/22"
}

data "azurerm_client_config" "current" {}

# --- management groups: <prefix> > platform (management, connectivity, identity, security)
#                                  > landing zones (corp, online) > sandbox, decommissioned
resource "azurerm_management_group" "root" {
  name                       = var.prefix
  display_name               = title(var.prefix)
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/${data.azurerm_client_config.current.tenant_id}"
}

resource "azurerm_management_group" "platform" {
  name                       = "${var.prefix}-platform"
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "platform_children" {
  for_each                   = toset(["management", "connectivity", "identity", "security"])
  name                       = "${var.prefix}-${each.key}"
  display_name               = title(each.key)
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "landing_zones" {
  name                       = "${var.prefix}-landingzones"
  display_name               = "Landing zones"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "lz_children" {
  for_each                   = toset(["corp", "online"])
  name                       = "${var.prefix}-${each.key}"
  display_name               = title(each.key)
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "other" {
  for_each                   = toset(["sandbox", "decommissioned"])
  name                       = "${var.prefix}-${each.key}"
  display_name               = title(each.key)
  parent_management_group_id = azurerm_management_group.root.id
}

# --- subscription placement: moving a subscription changes which policies apply. It moves no packets.
resource "azurerm_management_group_subscription_association" "connectivity" {
  management_group_id = azurerm_management_group.platform_children["connectivity"].id
  subscription_id     = "/subscriptions/${var.connectivity_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "management" {
  management_group_id = azurerm_management_group.platform_children["management"].id
  subscription_id     = "/subscriptions/${var.management_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "corp" {
  for_each            = toset(var.corp_subscription_ids)
  management_group_id = azurerm_management_group.lz_children["corp"].id
  subscription_id     = "/subscriptions/${each.value}"
}

# --- policies, inherited by everything below the scope they're assigned to
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations"
  management_group_id  = azurerm_management_group.root.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# Corp workloads reach the internet through the hub, so they don't get their own public IPs.
resource "azurerm_management_group_policy_assignment" "corp_no_public_ip" {
  name                 = "corp-no-public-ip"
  display_name         = "Corp: no public IP addresses"
  management_group_id  = azurerm_management_group.lz_children["corp"].id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749"
  parameters = jsonencode({
    listOfResourceTypesNotAllowed = { value = ["Microsoft.Network/publicIPAddresses"] }
  })
}

# --- hub network in the Connectivity subscription (spokes peer to it, see ../../hub-spoke-peering)
resource "azurerm_resource_group" "hub" {
  provider = azurerm.connectivity
  name     = "rg-${var.prefix}-hub"
  location = var.allowed_locations[0]
}

resource "azurerm_virtual_network" "hub" {
  provider            = azurerm.connectivity
  name                = "vnet-${var.prefix}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_address_space]
}

resource "azurerm_subnet" "hub" {
  provider             = azurerm.connectivity
  for_each             = { AzureFirewallSubnet = 0, GatewaySubnet = 1, AzureBastionSubnet = 2 } # fixed names Azure expects
  name                 = each.key
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_address_space, 4, each.value)] # /26 each from a /22
}
