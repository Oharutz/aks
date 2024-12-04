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