terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  # Remote state, read with Entra ID (no storage key). Fill in your own names.
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate00000"
    container_name       = "tfstate"
    key                  = "network/prod.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type    = string
  default = "rg-network-prod"
}

variable "location" {
  type    = string
  default = "westeurope"
}

# Rules are declared inline, so the NSG's full rule list is in code. A port-22 rule added in the portal then shows
# up in the next plan as a change to this resource. (With separate azurerm_network_security_rule resources, Terraform
# only sees the rules it manages and a hand-made extra rule stays invisible. Pick inline when you want drift detection.)
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-prod"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-https-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}
