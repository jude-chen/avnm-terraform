
data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "my-avnm" {
  name                = "tf-network-manager"
  location            = var.main_location
  resource_group_name = azurerm_resource_group.avnm-rg.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["Connectivity", "SecurityAdmin", "Routing"]
}

resource "azurerm_network_manager_network_group" "hub-network-group" {
  name               = "hub-group"
  network_manager_id = azurerm_network_manager.my-avnm.id
}

resource "azurerm_network_manager_network_group" "main-spoke-network-group" {
  name               = "main-spoke-group"
  network_manager_id = azurerm_network_manager.my-avnm.id
}

resource "azurerm_network_manager_network_group" "secondary-spoke-network-group" {
  name               = "secondary-spoke-group"
  network_manager_id = azurerm_network_manager.my-avnm.id
}

resource "azurerm_network_manager_static_member" "hub-members" {
  for_each                  = var.hub-vnets
  name                      = each.key
  network_group_id          = azurerm_network_manager_network_group.hub-network-group.id
  target_virtual_network_id = azurerm_virtual_network.vnets[each.key].id
}

resource "azurerm_network_manager_static_member" "main-spoke-members" {
  for_each                  = var.main-spoke-vnets
  name                      = each.key
  network_group_id          = azurerm_network_manager_network_group.main-spoke-network-group.id
  target_virtual_network_id = azurerm_virtual_network.vnets[each.key].id
}

resource "azurerm_network_manager_static_member" "secondary-spoke-members" {
  for_each                  = var.secondary-spoke-vnets
  name                      = each.key
  network_group_id          = azurerm_network_manager_network_group.secondary-spoke-network-group.id
  target_virtual_network_id = azurerm_virtual_network.vnets[each.key].id
}
