# Private DNS Zone for AKS
resource "azurerm_private_dns_zone" "aks_dns" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
}

# Private DNS Zone for ACR
resource "azurerm_private_dns_zone" "acr_dns" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

#data "azurerm_private_endpoint" "kube_apiserver" {
#  name                = "KUBE-APISERVER"
#  resource_group_name = var.resource_group_name
#}


# Virtual Network Link for AKS DNS
resource "azurerm_private_dns_zone_virtual_network_link" "aks_vnet_link" {
  name                  = "aks-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
  virtual_network_id    = var.aks_vnet_id
}

# Virtual Network Link for ACR DNS
resource "azurerm_private_dns_zone_virtual_network_link" "acr_vnet_link" {
  name                  = "acr-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns.name
  virtual_network_id    = var.aks_vnet_id
}

# DNS Record for AKS in Private Zone
resource "azurerm_private_dns_a_record" "aks_dns_record" {
  name                = "aks-api"
  zone_name           = azurerm_private_dns_zone.aks_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_dns_zone_virtual_network_link.aks_vnet_link.private_service_connection[0].private_ip_address]
}

# DNS Record for ACR in Private Zone
resource "azurerm_private_dns_a_record" "acr_dns_record" {
  name                = module.acr.name
  zone_name           = azurerm_private_dns_zone.acr_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_dns_zone_virtual_network_link.acr_vnet_link.private_service_connection[0].private_ip_address]
}
