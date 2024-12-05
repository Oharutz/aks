resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
}