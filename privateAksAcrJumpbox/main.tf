terraform {
  backend "azurerm" {
    resource_group_name  = "basicAksRg"
    storage_account_name = "tfstateaccount1296"
    container_name       = "tfstate"
    key                  = "env/terraform.tfstate"  # Use environment-specific key if needed
  }
}

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
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
}

module "aks" {
  source = "./modules/aks"
  prefix = var.prefix
  location = azurerm_resource_group.main.location
  aks_subnet_id = var.aks_subnet_id
  acr_id              = module.acr.acr_id
  resource_group_name = azurerm_resource_group.main.name
  
}

module "dns" {
  source   = "./modules/dns"
  location = var.location
  aks_id   = module.aks.aks_id
  acr_id   = module.acr.acr_id
  acr_name   = module.acr.acr_name
  resource_group_name = azurerm_resource_group.main.name
}