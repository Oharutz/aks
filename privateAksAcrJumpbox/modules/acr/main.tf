resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}
resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}${random_string.unique.result}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
  public_network_access_enabled = false
}