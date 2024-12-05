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

data "azurerm_private_endpoint" "kube_apiserver" {
  name                = "KUBE-APISERVER"
  resource_group_name = azurerm_resource_group.main.name
}


# Virtual Network Link for AKS DNS
#resource "azurerm_private_dns_zone_virtual_network_link" "aks_vnet_link" {
#  name                  = "aks-vnet-link"
#  resource_group_name   = azurerm_resource_group.main.name
#  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
#  virtual_network_id    = azurerm_virtual_network.main.id
#}

# Virtual Network Link for ACR DNS
resource "azurerm_private_dns_zone_virtual_network_link" "acr_vnet_link" {
  name                  = "acr-vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns.name
  virtual_network_id    = var.aks_vnet_id
}

# DNS Record for AKS in Private Zone
resource "azurerm_private_dns_a_record" "aks_dns_record" {
  name                = "aks-api"
  zone_name           = azurerm_private_dns_zone.aks_dns.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint.kube_apiserver.private_service_connection[0].private_ip_address]
#}

# DNS Record for ACR in Private Zone
resource "azurerm_private_dns_a_record" "acr_dns_record" {
  name                = azurerm_container_registry.main.name
  zone_name           = azurerm_private_dns_zone.acr_dns.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.acr_endpoint.private_service_connection[0].private_ip_address]
}
