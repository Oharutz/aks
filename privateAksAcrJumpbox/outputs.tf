output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "resource_group_location" {
  value = azurerm_resource_group.main.location
}

output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.aks_name
}