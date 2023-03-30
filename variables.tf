
variable "resource_group_name" {
  type        = string
  description = "The name of the IBM Cloud resource group where the cluster will be created/can be found."
}

variable "region" {
  type        = string
  description = "The region where the cluster has been provisioned"
}

variable "name" {
  type        = string
  description = "The name of the cluster. If not provided the name will be derived from the name_prefix and/or resource_group_name"
  default     = ""
}

variable "name_prefix" {
  type        = string
  description = "The prefix name for the service. If not provided it will default to the resource group name"
  default     = ""
}

variable "disable_public_endpoint" {
  type        = bool
  description = "Flag indicating that private endpoints should be used"
  default     = false
}
