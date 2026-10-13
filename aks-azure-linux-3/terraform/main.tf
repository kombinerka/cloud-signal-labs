# Keep the code in line after migrating, or the next apply puts the node pool back.
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

variable "cluster_id" {
  description = "Resource ID of the AKS cluster"
  type        = string
}

resource "azurerm_kubernetes_cluster_node_pool" "apps" {
  name                  = "apps"
  kubernetes_cluster_id = var.cluster_id
  vm_size               = "Standard_D4s_v5"
  os_sku                = "AzureLinux3" # was "AzureLinux" on Kubernetes < 1.32 (= Azure Linux 2.0)
  auto_scaling_enabled  = true
  min_count             = 2
  max_count             = 10
}
