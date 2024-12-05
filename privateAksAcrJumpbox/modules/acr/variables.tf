variable "prefix" {
  type        = string
  description = "Prefix for naming resources"
  default = "privateAks"
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}