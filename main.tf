provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-private-vnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_user_assigned_identity" "uami" {
  name                = "aks-managed-identity"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Subnet for Private Link (Optional)
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Private DNS Zone for AKS
resource "azurerm_private_dns_zone" "private_dns" {
  name                = "privatelink.westus.azmk8s.io"
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Private DNS Zone Link to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  resource_group_name   = azurerm_resource_group.aks_rg.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_kubernetes_cluster" "aks_private" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aks-private"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.dns_link
  ]
}
output "aks_cluster_name" {
    value = azurerm_kubernetes_cluster.aks_private.name
}

output "aks_private_fqdn" {
    value = azurerm_kubernetes_cluster.aks_private.private_fqdn
}
