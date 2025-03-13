resource "azurerm_resource_group" "avnm-rg" {
  name     = "avnm-demo-rg"
  location = var.main_location
}

resource "azurerm_virtual_network" "hub-vnets" {
  count = 2

  name                = "hub-vnet-0${count.index}"
  resource_group_name = azurerm_resource_group.avnm-rg.name
  location            = (count.index % 2 == 0 ? var.main_location : var.secondary_location)
  address_space       = ["10.0.${count.index}.0/24"]
}

# Add a subnet to each virtual network

resource "azurerm_subnet" "hub-subnets" {
  count = 2

  name                 = "default"
  virtual_network_name = azurerm_virtual_network.hub-vnets[count.index].name
  resource_group_name  = azurerm_resource_group.avnm-rg.name
  address_prefixes     = ["10.0.${count.index}.0/26"]
}


resource "azurerm_virtual_network" "main-spoke-vnets" {
  count = 2

  name                = "main-spoke-vnet-0${count.index}"
  resource_group_name = azurerm_resource_group.avnm-rg.name
  location            = var.main_location
  address_space       = ["10.1.${count.index}.0/24"]
}

# Add a subnet to each virtual network

resource "azurerm_subnet" "main-spoke-subnets" {
  count = 2

  name                 = "default"
  virtual_network_name = azurerm_virtual_network.main-spoke-vnets[count.index].name
  resource_group_name  = azurerm_resource_group.avnm-rg.name
  address_prefixes     = ["10.1.${count.index}.0/26"]
}

resource "azurerm_virtual_network" "secondary-spoke-vnets" {
  count = 3

  name                = "secondary-spoke-vnet-0${count.index}"
  resource_group_name = azurerm_resource_group.avnm-rg.name
  location            = var.secondary_location
  address_space       = ["10.2.${count.index}.0/24"]
}

# Add a subnet to each virtual network

resource "azurerm_subnet" "secondary-spoke-subnets" {
  count = 2

  name                 = "default"
  virtual_network_name = azurerm_virtual_network.secondary-spoke-vnets[count.index].name
  resource_group_name  = azurerm_resource_group.avnm-rg.name
  address_prefixes     = ["10.2.${count.index}.0/26"]
}
