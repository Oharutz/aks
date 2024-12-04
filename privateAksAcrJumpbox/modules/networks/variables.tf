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