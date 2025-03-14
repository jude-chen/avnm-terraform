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

resource "azurerm_network_manager_connectivity_configuration" "spoke-confs" {
  for_each = {
    main = {
      network_group_id = azurerm_network_manager_network_group.main-spoke-network-group.id
      hub_id           = azurerm_virtual_network.vnets["main-hub-vnet-01"].id
    },
    secondary = {
      network_group_id = azurerm_network_manager_network_group.secondary-spoke-network-group.id
      hub_id           = azurerm_virtual_network.vnets["secondary-hub-vnet-01"].id
    }
  }
  name                  = "${each.key}-spoke-conf"
  network_manager_id    = azurerm_network_manager.my-avnm.id
  connectivity_topology = "HubAndSpoke"
  applies_to_group {
    group_connectivity = "None"
    network_group_id   = each.value.network_group_id
  }
  hub {
    resource_id   = each.value.hub_id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
}

resource "azurerm_network_manager_deployment" "hub-connectivity-deployment" {
  for_each           = { main = var.main_location, secondary = var.secondary_location }
  network_manager_id = azurerm_network_manager.my-avnm.id
  location           = each.value
  scope_access       = "Connectivity"
  configuration_ids = [
    azurerm_network_manager_connectivity_configuration.hub-mesh-conf.id,
    azurerm_network_manager_connectivity_configuration.spoke-confs[each.key].id
  ]
  triggers = {
    group_connectivity = join(",", flatten([for conf in [azurerm_network_manager_connectivity_configuration.hub-mesh-conf, azurerm_network_manager_connectivity_configuration.spoke-confs[each.key]] : conf.applies_to_group.*.group_connectivity]))
    network_group_id   = join(",", flatten([for conf in [azurerm_network_manager_connectivity_configuration.hub-mesh-conf, azurerm_network_manager_connectivity_configuration.spoke-confs[each.key]] : conf.applies_to_group.*.network_group_id]))
    hub_id             = join(",", azurerm_network_manager_connectivity_configuration.spoke-confs[each.key].hub.*.resource_id)
  }
}
