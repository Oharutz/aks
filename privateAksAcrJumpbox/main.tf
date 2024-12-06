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

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "resource_group_location" {
  value = azurerm_resource_group.main.location
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

output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.aks_name
}

module "dns" {
  source   = "./modules/dns"
  location = var.location
  aks_id   = module.aks.aks_id
  acr_id   = module.acr.acr_id
  acr_name   = module.acr.acr_name
  resource_group_name = azurerm_resource_group.main.name
}