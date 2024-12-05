
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
    vnet_subnet_id = var.aks_subnet_id
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

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
