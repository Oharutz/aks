provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "acr" {
  source = "./modules/acr"
  prefix = var.prefix
}

module "aks" {
  source = "./modules/aks"
  prefix = var.prefix
  location = var.location
  aks_subnet_id = var.aks_subnet_id
}

module "dns" {
  source = "./modules/dns"
  location = var.location
}