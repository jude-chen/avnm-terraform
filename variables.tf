variable "main_location" {
  description = "The Azure location where the resources will be created."
  type        = string
  default     = "northcentralus"
}

variable "secondary_location" {
  description = "The secondary Azure location for geo-redundancy."
  type        = string
  default     = "southcentralus"
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
  default     = "49a8be25-7877-4460-a634-7c9c60a5be08"
}
