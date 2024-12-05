variable "admin_password" {
  type        = string
  description = "Prefix for naming resources"
  default     = "Aa123456789!!"
  sensitive   = true
}
variable "location" {
  type        = string
  description = "Azure region for the resources"
  default     = "westus"
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default = "privateAksRg"
}