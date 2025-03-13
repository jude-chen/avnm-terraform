resource "azurerm_network_manager_security_admin_configuration" "securityadmin-conf" {
  name               = "security-admin-conf"
  network_manager_id = azurerm_network_manager.my-avnm.id
}

resource "azurerm_network_manager_admin_rule_collection" "admin-rule-collection" {
  name                            = "admin-rule-collection"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.securityadmin-conf.id
  network_group_ids = [
    azurerm_network_manager_network_group.hub-network-group.id,
    azurerm_network_manager_network_group.main-spoke-network-group.id,
    azurerm_network_manager_network_group.secondary-spoke-network-group.id
  ]
}

resource "azurerm_network_manager_admin_rule" "admin-rule-01" {
  name                     = "deny-http-outbound"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.admin-rule-collection.id
  action                   = "Deny"
  direction                = "Outbound"
  priority                 = 100
  protocol                 = "Tcp"
  source_port_ranges       = ["80", "1024-65535"]
  destination_port_ranges  = ["80"]
  source {
    address_prefix_type = "IPPrefix"
    address_prefix      = "10.0.0.0/8"
  }
  destination {
    address_prefix_type = "ServiceTag"
    address_prefix      = "Internet"
  }
}

resource "azurerm_network_manager_admin_rule" "admin-rule-02" {
  name                     = "deny-ssh-outbound"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.admin-rule-collection.id
  action                   = "Deny"
  direction                = "Outbound"
  priority                 = 200
  protocol                 = "Tcp"
  source_port_ranges       = ["22", "1024-65535"]
  destination_port_ranges  = ["22"]
  source {
    address_prefix_type = "IPPrefix"
    address_prefix      = "10.0.0.0/8"
  }
  destination {
    address_prefix_type = "ServiceTag"
    address_prefix      = "Internet"
  }
}

resource "azurerm_network_manager_deployment" "securityadmin-deployments" {
  for_each           = { main = var.main_location, secondary = var.secondary_location }
  network_manager_id = azurerm_network_manager.my-avnm.id
  location           = each.value
  scope_access       = "SecurityAdmin"
  configuration_ids  = [azurerm_network_manager_security_admin_configuration.securityadmin-conf.id]
  depends_on = [
    azurerm_network_manager_admin_rule.admin-rule-01,
    azurerm_network_manager_admin_rule.admin-rule-02
  ]
  # Note: The depends_on attribute ensures that the rule collections are created before the deployment.
  triggers = {
    source_port_ranges         = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.source_port_ranges]))
    destination_port_ranges    = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.destination_port_ranges]))
    source_address_prefix      = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.source.*.address_prefix]))
    destination_address_prefix = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.destination.*.address_prefix]))
    action                     = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.action]))
    direction                  = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.direction]))
    priority                   = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.priority]))
    protocol                   = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.protocol]))
    rule_name                  = join(",", flatten([for rule in [azurerm_network_manager_admin_rule.admin-rule-01, azurerm_network_manager_admin_rule.admin-rule-02] : rule.name]))
  }
}
