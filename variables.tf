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

variable "hub-vnets" {
  description = "List of the hub virtual networks to be created."
  type = map(object({
    address_space = list(string)
    location      = string
  }))
  default = {
    "main-hub-vnet-01" = {
      address_space = ["10.0.0.0/24"]
      location      = "northcentralus"
    },
    "secondary-hub-vnet-01" = {
      address_space = ["10.1.0.0/24"]
      location      = "southcentralus"
    }
  }
}

variable "main-spoke-vnets" {
  description = "List of the spoke virtual networks in the main location to be created."
  type = map(object({
    address_space = list(string)
    location      = string
  }))
  default = {
    "main-spoke-vnet-01" = {
      address_space = ["10.0.1.0/24"]
      location      = "northcentralus"
    },
    "main-spoke-vnet-02" = {
      address_space = ["10.0.2.0/24"]
      location      = "northcentralus"
    }
  }
}

variable "secondary-spoke-vnets" {
  description = "List of the spoke virtual networks in the secondary location to be created."
  type = map(object({
    address_space = list(string)
    location      = string
  }))
  default = {
    "secondary-spoke-vnet-01" = {
      address_space = ["10.1.1.0/24"]
      location      = "southcentralus"
    },
    "secondary-spoke-vnet-02" = {
      address_space = ["10.1.2.0/24"]
      location      = "southcentralus"
    }
  }
}

variable "subnets" {
  description = "List of subnets to be created in each virtual network."
  type = map(object({
    vnet-name        = string
    address_prefixes = list(string)
  }))
  default = {
    "main-hub-subnet-01" = {
      vnet-name        = "main-hub-vnet-01"
      address_prefixes = ["10.0.0.0/26"]
    },
    "secondary-hub-subnet-01" = {
      vnet-name        = "secondary-hub-vnet-01"
      address_prefixes = ["10.1.0.0/26"]
    },
    "main-spoke-subnet-01" = {
      vnet-name        = "main-spoke-vnet-01"
      address_prefixes = ["10.0.1.0/26"]
    },
    "main-spoke-subnet-02" = {
      vnet-name        = "main-spoke-vnet-02"
      address_prefixes = ["10.0.2.0/26"]
    },
    "secondary-spoke-subnet-01" = {
      vnet-name        = "secondary-spoke-vnet-01"
      address_prefixes = ["10.1.1.0/26"]
    },
    "secondary-spoke-subnet-02" = {
      vnet-name        = "secondary-spoke-vnet-02"
      address_prefixes = ["10.1.2.0/26"]
    }
  }
}
