# The chain from the video: a VM with a system-assigned managed identity reads a secret from Key Vault.
# Identity on, token for the right audience, network path, and a role on the right scope: all four are needed.
#   terraform apply -var name=<unique-suffix> -var "ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)"
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
  description = "Short unique suffix (Key Vault names are global)"
  type        = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "ssh_public_key" {
  type = string
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "mi" {
  name     = "rg-mi-${var.name}"
  location = var.location
}

# --- the target: Key Vault in RBAC mode (permissions are Azure role assignments, not access policies)
resource "azurerm_key_vault" "app" {
  name                       = "kv-mi-${var.name}"
  location                   = azurerm_resource_group.mi.location
  resource_group_name        = azurerm_resource_group.mi.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
}

# You (the deployer) need data-plane rights to create the secret.
resource "azurerm_role_assignment" "deployer_secrets_officer" {
  scope                = azurerm_key_vault.app.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "db" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.app.id
  depends_on   = [azurerm_role_assignment.deployer_secrets_officer]
}

# --- the caller: a VM with a system-assigned identity (created and deleted with the VM)
resource "azurerm_virtual_network" "mi" {
  name                = "vnet-mi"
  location            = azurerm_resource_group.mi.location
  resource_group_name = azurerm_resource_group.mi.name
  address_space       = ["10.20.0.0/24"]
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.mi.name
  virtual_network_name = azurerm_virtual_network.mi.name
  address_prefixes     = ["10.20.0.0/26"]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-mi"
  location            = azurerm_resource_group.mi.location
  resource_group_name = azurerm_resource_group.mi.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                  = "vm-mi-app"
  location              = azurerm_resource_group.mi.location
  resource_group_name   = azurerm_resource_group.mi.name
  size                  = "Standard_B2s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm.id]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# --- authorization: without this, the token is valid, the identity is real, and access is still denied.
# Narrowest useful scope: the vault (or even the single secret), role: read secret values only.
resource "azurerm_role_assignment" "vm_secrets_user" {
  scope                = azurerm_key_vault.app.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.app.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

output "vault_url" {
  value = azurerm_key_vault.app.vault_uri
}

output "vm_principal_id" {
  value = azurerm_linux_virtual_machine.app.identity[0].principal_id
}
