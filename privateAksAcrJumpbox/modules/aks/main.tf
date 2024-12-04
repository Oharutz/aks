
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.prefix}-dns"
  http_application_routing_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  private_cluster_enabled         = true
  api_server_authorized_ip_ranges = []

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }
  web_app_routing {
    dns_zone_ids = [azurerm_private_dns_zone.aks_dns.id]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

resource "azurerm_virtual_network_peering" "vmss_to_aks" {
  name                      = "vmss-to-aks-peering"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = var.vmss_vnet_name
  remote_virtual_network_id = var.aks_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = false
  allow_gateway_transit     = false
}

resource "azurerm_virtual_network_peering" "aks_to_vmss" {
  name                      = "aks-to-vmss-peering"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = var.aks_vnet_name
  remote_virtual_network_id = var.vmss_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = false
  allow_gateway_transit     = false
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}