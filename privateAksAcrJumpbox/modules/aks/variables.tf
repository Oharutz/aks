variable "prefix" {
  type        = string
  description = "Prefix for naming resources"
  default = "privateAks"
}

variable "location" {
  type        = string
  description = "Azure region for the resources"
  default     = "westus"
}

variable "vmss_vnet_name" {
  type        = string
  description = "The name of the VNet containing the VMSS."
  default     = "AzDevopsvNet"
}