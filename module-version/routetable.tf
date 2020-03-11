#create Route Tables
#Management to Firewall
resource "azurerm_route_table" "route-hubvnet-managementsubnet" {
  name                = "route-hubvnet-managementsubnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_firewall.azfirewall, azurerm_firewall_application_rule_collection.azfirewall-apprules]
}

resource "azurerm_route" "hubvnet-managementsubnet-to-internet" {
  name                = "hubvnet-managementsubnet-to-internet"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route-hubvnet-managementsubnet.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.8.4"
  depends_on = [azurerm_route_table.route-hubvnet-managementsubnet]
}
resource "azurerm_subnet_route_table_association" "route-hubvnet-managementsubnet-ass" {
  subnet_id      = azurerm_subnet.managementsubnet.id
  route_table_id = azurerm_route_table.route-hubvnet-managementsubnet.id
  depends_on = [azurerm_route_table.route-hubvnet-managementsubnet]
}
#Web to Firewall
resource "azurerm_route_table" "route-spokevnet-websubnet" {
  name                = "route-spokevnet-websubnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_firewall.azfirewall, azurerm_firewall_application_rule_collection.azfirewall-apprules]
}

resource "azurerm_route" "spokevnet-websubnet-to-internet" {
  name                = "spokevnet-websubnet-to-internet"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route-spokevnet-websubnet.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.8.4"
  depends_on = [azurerm_route_table.route-spokevnet-websubnet]
}
resource "azurerm_subnet_route_table_association" "route-spokevnet-websubnet-ass" {
  subnet_id      = azurerm_subnet.websubnet.id
  route_table_id = azurerm_route_table.route-spokevnet-websubnet.id
  depends_on = [azurerm_route_table.route-spokevnet-websubnet]
}
#on prem to Firewall
resource "azurerm_route_table" "route-onpremvnet-onpresubnet" {
  name                = "route-onpremvnet-onpresubnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_firewall.azfirewall, azurerm_firewall_application_rule_collection.azfirewall-apprules]
}

resource "azurerm_route" "onpremvnet-onpresubnet-to-hubvnet" {
  name                = "onpremvnet-onpresubnet-to-hubvnet"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route-onpremvnet-onpresubnet.name
  address_prefix      = "10.0.1.0/27"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.8.4"
  depends_on = [azurerm_route_table.route-onpremvnet-onpresubnet]
}
resource "azurerm_subnet_route_table_association" "route-onpremvnet-onpresubnet-ass" {
  subnet_id      = azurerm_subnet.gatewaysubnet.id
  route_table_id = azurerm_route_table.route-onpremvnet-onpresubnet.id
  depends_on = [azurerm_route_table.route-onpremvnet-onpresubnet]
}
