# Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

#Azure provider
provider "azurerm" {
  features {}
}

module "aks_cluster" {
  source = "./module"

  for_each = toset(["cluster1", "cluster2", "cluster3"])
  resource_group_name = "rg-${each.key}"
  location            = "East US"  # Replace with the desired location
  cluster_name        = "aks-${each.key}"
  dns_prefix          = "dns-${each.key}"
  node_count          = 1
}
