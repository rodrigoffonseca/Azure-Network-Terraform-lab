# create VPN Gateway HUB VNET
resource "azurerm_public_ip" "hubvpngw-pip" {
  name                = "hubvpngw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hubvpngw" {
  name                = "hubvpngw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hubvpngw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet.id
  }
}

# create VPN Gateway On-Premises VNET
resource "azurerm_public_ip" "onpremvpngw-pip" {
  name                = "onpremvpngw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onpremvpngw" {
  name                = "onpremvpngw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onpremvpngw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onpremgatewaysubnet.id
  }
}
#create VPN Gateway Connections
resource "azurerm_virtual_network_gateway_connection" "Hub-to-Onprem-vpn" {
  name                = "Hub-to-Onprem-vpn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hubvpngw.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onpremvpngw.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_virtual_network_gateway_connection" "Onprem-to-hub-vpn" {
  name                = "Onprem-to-hub-vpn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onpremvpngw.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hubvpngw.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}