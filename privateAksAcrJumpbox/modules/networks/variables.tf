variable "prefix" {
  type        = string
  description = "Prefix for naming resources"
  default = "privateAks"
}

variable "aks_vnet_id" {
  type        = string
  description = "The VNET ID For the AKS Cluster"
  default     = "/subscriptions/54da8c11-3fc8-4363-ac36-2ded76e48576/resourceGroups/networkingRg/providers/Microsoft.Network/virtualNetworks/demoEnvSubnet"
}

variable "location" {
  type        = string
  description = "Azure region for the resources"
  default     = "westus"
}