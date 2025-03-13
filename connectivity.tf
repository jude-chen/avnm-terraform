resource "azurerm_network_manager_connectivity_configuration" "hub-mesh-conf" {
  name                  = "hub-mesh-conf"
  network_manager_id    = azurerm_network_manager.my-avnm.id
  connectivity_topology = "Mesh"
  applies_to_group {
    group_connectivity  = "DirectlyConnected"
    network_group_id    = azurerm_network_manager_network_group.hub-network-group.id
    global_mesh_enabled = true
  }
}

resource "azurerm_network_manager_connectivity_configuration" "main-spoke-conf" {
  name                  = "main-spoke-conf"
  network_manager_id    = azurerm_network_manager.my-avnm.id
  connectivity_topology = "HubAndSpoke"
  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.main-spoke-network-group.id
  }
  hub {
    resource_id   = azurerm_virtual_network.hub-vnets[0].id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
}

resource "azurerm_network_manager_connectivity_configuration" "secondary-spoke-conf" {
  name                  = "secondary-spoke-conf"
  network_manager_id    = azurerm_network_manager.my-avnm.id
  connectivity_topology = "HubAndSpoke"
  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.secondary-spoke-network-group.id
  }
  hub {
    resource_id   = azurerm_virtual_network.hub-vnets[1].id
    resource_type = "Microsoft.Network/virtualNetworks"
  }

}

resource "azurerm_network_manager_deployment" "connectivity-deployments" {
  for_each           = { main = var.main_location, secondary = var.secondary_location }
  network_manager_id = azurerm_network_manager.my-avnm.id
  location           = each.value
  scope_access       = "Connectivity"
  configuration_ids = [
    azurerm_network_manager_connectivity_configuration.hub-mesh-conf.id,
    azurerm_network_manager_connectivity_configuration.main-spoke-conf.id,
    azurerm_network_manager_connectivity_configuration.secondary-spoke-conf.id
  ]
}
