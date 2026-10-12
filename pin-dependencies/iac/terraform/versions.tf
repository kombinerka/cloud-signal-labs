# Terraform: pin Terraform, providers and modules. Commit .terraform.lock.hcl: it records the exact provider
# version and its checksums, so every run (and every colleague) uses the same provider build.
#   terraform init                       # creates/updates .terraform.lock.hcl
#   terraform providers lock -platform=linux_amd64 -platform=windows_amd64 -platform=darwin_arm64
terraform {
  required_version = "~> 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.9.0" # patch updates only; the lock file pins the exact build
    }
  }
}

provider "azurerm" {
  features {}
}

# Registry modules: an exact version, never an open range. Git modules: a commit SHA as ref, not a branch.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"
}

# module "network" {
#   source = "git::https://github.com/my-org/terraform-modules.git//network?ref=0123456789abcdef0123456789abcdef01234567"
# }
