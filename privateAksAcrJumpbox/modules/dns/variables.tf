variable "location" {
  type        = string
  description = "Azure region for the resources"
  default     = "westus"
}
variable "aks_subnet_id" {
  type        = string
  description = "The SUBNET ID For the AKS Cluster"
  default     = "/subscriptions/54da8c11-3fc8-4363-ac36-2ded76e48576/resourceGroups/management/providers/Microsoft.Network/virtualNetworks/demoEnvVnet/subnets/aks"
}
variable "aks_vnet_id" {
  type        = string
  description = "The VNET ID For the AKS Cluster"
  default     = "/subscriptions/54da8c11-3fc8-4363-ac36-2ded76e48576/resourceGroups/management/providers/Microsoft.Network/virtualNetworks/demoEnvVnet"
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default = "privateAksRg"
}
variable "aks_id" {
  description = "The ID of the AKS Cluster"
  type        = string
}
variable "acr_name" {
  description = "The name of the ACR"
  type        = string
}
variable "acr_id" {
  description = "The ID of the ACR"
  type        = string
}