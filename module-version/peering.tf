#Configure Virtual Network Peering
resource "azurerm_virtual_network_peering" "Hub2Spoke" {
  name                      = "Hub2Spoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id = azurerm_virtual_network.spokevnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = true
  depends_on = [azurerm_virtual_network_gateway_connection.Onprem-to-hub-vpn, azurerm_virtual_network_gateway_connection.Hub-to-Onprem-vpn]
}

resource "azurerm_virtual_network_peering" "Spoke2Hub" {
  name                      = "Spoke2Hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spokevnet.name
  remote_virtual_network_id = azurerm_virtual_network.hubvnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways = true
  depends_on = [azurerm_virtual_network_gateway_connection.Onprem-to-hub-vpn, azurerm_virtual_network_gateway_connection.Hub-to-Onprem-vpn]
}