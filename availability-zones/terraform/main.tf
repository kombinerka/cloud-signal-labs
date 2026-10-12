# Three web VMs spread across availability zones 1, 2 and 3, behind a zone-redundant Standard load balancer.
# One zone fails: the load balancer's health probe stops sending traffic there, the other two keep serving.
#   terraform apply -var "ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)"
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
  description = "A region with availability zones"
  type        = string
  default     = "westeurope"
}

variable "ssh_public_key" {
  type = string
}

resource "azurerm_resource_group" "shop" {
  name     = "rg-shop-zones"
  location = var.location
}

resource "azurerm_virtual_network" "shop" {
  name                = "vnet-shop"
  location            = azurerm_resource_group.shop.location
  resource_group_name = azurerm_resource_group.shop.name
  address_space       = ["10.10.0.0/24"]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.shop.name
  virtual_network_name = azurerm_virtual_network.shop.name
  address_prefixes     = ["10.10.0.0/25"]
}

# Standard public IP across zones 1-3: it keeps working when one zone is down.
resource "azurerm_public_ip" "lb" {
  name                = "pip-shop"
  location            = azurerm_resource_group.shop.location
  resource_group_name = azurerm_resource_group.shop.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_lb" "shop" {
  name                = "lb-shop"
  location            = azurerm_resource_group.shop.location
  resource_group_name = azurerm_resource_group.shop.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "web"
  loadbalancer_id = azurerm_lb.shop.id
}

resource "azurerm_lb_probe" "http" {
  name            = "http"
  loadbalancer_id = azurerm_lb.shop.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "http" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.shop.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.shop.location
  resource_group_name = azurerm_resource_group.shop.name

  security_rule {
    name                       = "allow-http-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# Flexible scale set: 3 instances, spread over zones 1, 2 and 3.
resource "azurerm_orchestrated_virtual_machine_scale_set" "web" {
  name                        = "vmss-web"
  location                    = azurerm_resource_group.shop.location
  resource_group_name         = azurerm_resource_group.shop.name
  sku_name                    = "Standard_B2s"
  instances                   = 3
  zones                       = ["1", "2", "3"]
  zone_balance                = true
  platform_fault_domain_count = 1

  os_profile {
    custom_data = base64encode("#!/bin/sh\napt-get update && apt-get install -y nginx\necho \"zone: $(curl -s -H Metadata:true 'http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01&format=text')\" > /var/www/html/index.html\n")
    linux_configuration {
      admin_username                  = "azureuser"
      disable_password_authentication = true
      admin_ssh_key {
        username   = "azureuser"
        public_key = var.ssh_public_key
      }
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic"
    primary = true
    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }

  depends_on = [azurerm_lb_rule.http]
}

output "url" {
  value = "http://${azurerm_public_ip.lb.ip_address}"
}
