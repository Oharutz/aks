provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.kubernetes_cluster_name}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.224.0.0/12"]
}

# Create a Subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.kubernetes_cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.224.0.0/16"]
}

# Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "main" {
  name                = "${var.kubernetes_cluster_name}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"
  admin_enabled       = true
}

# Create an AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.kubernetes_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.kubernetes_cluster_name}-dns"
  private_cluster_enabled = false

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.main.id
  }

  identity {
    type = "SystemAssigned"
  }
}

# Assign ACR Pull Role to AKS System Identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

# Private DNS Zone for AKS
resource "azurerm_private_dns_zone" "aks_dns" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.main.name
}

# Private DNS Zone for ACR
resource "azurerm_private_dns_zone" "acr_dns" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name
}

# Virtual Network Link for AKS DNS
resource "azurerm_private_dns_zone_virtual_network_link" "aks_vnet_link" {
  name                  = "aks-vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Virtual Network Link for ACR DNS
resource "azurerm_private_dns_zone_virtual_network_link" "acr_vnet_link" {
  name                  = "acr-vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Private Endpoint for AKS API Server
resource "azurerm_private_endpoint" "aks_endpoint" {
  name                = "aks-private-endpoint"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.main.id

  private_service_connection {
    name                           = "aks-connection"
    private_connection_resource_id = azurerm_kubernetes_cluster.main.id
    subresource_names              = ["management"]
    is_manual_connection           = false
  }
}

# Private Endpoint for ACR
resource "azurerm_private_endpoint" "acr_endpoint" {
  name                = "acr-private-endpoint"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.main.id

  private_service_connection {
    name                           = "acr-connection"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

# DNS Record for AKS in Private Zone
resource "azurerm_private_dns_a_record" "aks_dns_record" {
  name                = "aks-api"
  zone_name           = azurerm_private_dns_zone.aks_dns.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.aks_endpoint.private_service_connection[0].private_ip_address]
}

# DNS Record for ACR in Private Zone
resource "azurerm_private_dns_a_record" "acr_dns_record" {
  name                = azurerm_container_registry.main.name
  zone_name           = azurerm_private_dns_zone.acr_dns.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.acr_endpoint.private_service_connection[0].private_ip_address]
}
