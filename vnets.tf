resource "azurerm_resource_group" "avnm-rg" {
  name     = "avnm-demo-rg"
  location = var.main_location
}

resource "azurerm_virtual_network" "vnets" {
  for_each = merge(
    var.hub-vnets,
    var.main-spoke-vnets,
    var.secondary-spoke-vnets
  )
  name                = each.key
  resource_group_name = azurerm_resource_group.avnm-rg.name
  location            = each.value.location
  address_space       = each.value.address_space
}

# Add a subnet to each virtual network

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.vnets[each.value.vnet-name].name
  resource_group_name  = azurerm_resource_group.avnm-rg.name
  address_prefixes     = each.value.address_prefixes
}
