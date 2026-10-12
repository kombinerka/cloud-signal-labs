# Application Gateway v2 in front of a hostname-sensitive backend (e.g. an App Service app or a virtual-host web
# server). The fix from the video: the custom probe sends the hostname the app expects, and so do the requests.
#   terraform apply -var backend_fqdn=myapp.azurewebsites.net
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

variable "backend_fqdn" {
  description = "The backend's hostname, e.g. myapp.azurewebsites.net"
  type        = string
}

variable "health_path" {
  type    = string
  default = "/health"
}

locals {
  frontend_ip = "public"
  pool        = "app"
  settings    = "app-https"
  probe       = "app-health"
}

resource "azurerm_resource_group" "gw" {
  name     = "rg-appgw"
  location = var.location
}

resource "azurerm_virtual_network" "gw" {
  name                = "vnet-appgw"
  location            = azurerm_resource_group.gw.location
  resource_group_name = azurerm_resource_group.gw.name
  address_space       = ["10.30.0.0/24"]
}

resource "azurerm_subnet" "gw" {
  name                 = "snet-appgw" # Application Gateway needs its own subnet
  resource_group_name  = azurerm_resource_group.gw.name
  virtual_network_name = azurerm_virtual_network.gw.name
  address_prefixes     = ["10.30.0.0/26"]
}

resource "azurerm_public_ip" "gw" {
  name                = "pip-appgw"
  location            = azurerm_resource_group.gw.location
  resource_group_name = azurerm_resource_group.gw.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_application_gateway" "gw" {
  name                = "agw-shop"
  location            = azurerm_resource_group.gw.location
  resource_group_name = azurerm_resource_group.gw.name
  zones               = ["1", "2", "3"]

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gw-ip"
    subnet_id = azurerm_subnet.gw.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip
    public_ip_address_id = azurerm_public_ip.gw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = local.frontend_ip
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  backend_address_pool {
    name  = local.pool
    fqdns = [var.backend_fqdn]
  }

  # Requests to the backend carry the backend's hostname as Host (not the gateway's or an IP).
  backend_http_settings {
    name                                = local.settings
    protocol                            = "Https"
    port                                = 443
    cookie_based_affinity               = "Disabled"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true # or: host_name = "app.example.test" for a fixed hostname
    probe_name                          = local.probe
  }

  # THE FIX: a custom probe that sends the hostname the app expects and checks a real health path.
  # Without it, the default probe sends the backend's IP as Host -> 404 from a hostname-sensitive app ->
  # unhealthy backend -> no healthy server -> 502 for every user request.
  probe {
    name                                      = local.probe
    protocol                                  = "Https"
    path                                      = var.health_path
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true # or: host = "app.example.test"
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    name                       = "app"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = local.pool
    backend_http_settings_name = local.settings
  }
}
