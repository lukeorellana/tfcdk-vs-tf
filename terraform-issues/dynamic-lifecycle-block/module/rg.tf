
#create resource group
resource "azurerm_resource_group" "rg" {
    name     = "rg-${var.name}"
    location = var.location
    tags      = {
      Environment = "terraexample"
    }

    lifecycle {
      ignore_changes = var.tags_to_ignore
    }


}