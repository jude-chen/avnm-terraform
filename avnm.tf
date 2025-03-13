
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
  count                     = 2
  name                      = "hub-members${count.index}"
  network_group_id          = azurerm_network_manager_network_group.hub-network-group.id
  target_virtual_network_id = azurerm_virtual_network.hub-vnets[count.index].id
}

resource "azurerm_network_manager_static_member" "main-spoke-members" {
  count                     = 2
  name                      = "main-spoke-members${count.index}"
  network_group_id          = azurerm_network_manager_network_group.main-spoke-network-group.id
  target_virtual_network_id = azurerm_virtual_network.main-spoke-vnets[count.index].id
}

resource "azurerm_network_manager_static_member" "secondary-spoke-members" {
  count                     = 3
  name                      = "secondary-spoke-members${count.index}"
  network_group_id          = azurerm_network_manager_network_group.secondary-spoke-network-group.id
  target_virtual_network_id = azurerm_virtual_network.secondary-spoke-vnets[count.index].id
}
