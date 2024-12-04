provider "azurerm" {
  features {}
}

module "networks" {
  source = "./modules/networks"
  prefix = var.prefix
  location = var.location
}

module "aks" {
  source = "./modules/aks"
  prefix = var.prefix
  location = var.location
  vnet_id = module.networks.vnet_id
  subnet_id = module.networks.aks_subnet_id
}

module "dns" {
  source = "./modules/dns"
  location = var.location
}