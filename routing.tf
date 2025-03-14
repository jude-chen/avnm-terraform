resource "azapi_resource" "routing-confs" {
  for_each = {
    main      = "main",
    secondary = "secondary"
  }
  type      = "Microsoft.Network/networkManagers/routingConfigurations@2024-05-01"
  parent_id = azurerm_network_manager.my-avnm.id
  name      = "routing-conf-${each.key}"
  body = {
    properties = {
      description = "Routing configuration for the network manager"
    }
  }
}

resource "azapi_resource" "routing-rule-collections" {
  for_each = {
    main      = azurerm_network_manager_network_group.main-spoke-network-group.id,
    secondary = azurerm_network_manager_network_group.secondary-spoke-network-group.id
  }
  type      = "Microsoft.Network/networkManagers/routingConfigurations/ruleCollections@2024-05-01"
  parent_id = azapi_resource.routing-confs[each.key].id
  name      = "routing-rule-collection-${each.key}"
  body = {
    properties = {
      appliesTo = [
        {
          networkGroupId = each.value
        }
      ]
      disableBgpRoutePropagation = "true"
    }
  }
}

resource "azapi_resource" "default-routing-rules" {
  for_each = {
    main      = "10.0.0.4",
    secondary = "10.1.0.4"
  }
  type      = "Microsoft.Network/networkManagers/routingConfigurations/ruleCollections/rules@2024-05-01"
  parent_id = azapi_resource.routing-rule-collections[each.key].id
  name      = "default-routing-rule-${each.key}"
  body = {
    properties = {
      destination = {
        destinationAddress = "0.0.0.0/0"
        type               = "AddressPrefix"
      }
      nextHop = {
        nextHopAddress = each.value
        nextHopType    = "VirtualAppliance"
      }
    }
  }
}

