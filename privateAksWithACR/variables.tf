variable "location" {
  description = "The Azure region to deploy the resources."
  type        = string
  default     = "westus"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "aksResourceGroup"
}

variable "kubernetes_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "basicaks"
}
