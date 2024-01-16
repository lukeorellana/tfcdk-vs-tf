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

# resource group module
module "rg" {
  source = "./module"

  name     = "application"
  location = "eastus"
  tags_to_ignore = [tags["Environment"]]

}