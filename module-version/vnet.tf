# Create HUB VNET AND SUBNETS
# Create virtual network
resource "azurerm_virtual_network" "hubvnet" {
    name                = "hubvnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "gatewaysubnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hubvnet.name
    address_prefix       = "10.0.1.0/27"
}

resource "azurerm_subnet" "managementsubnet" {
    name                 = "managementsubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hubvnet.name
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "AzureFirewallSubnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hubvnet.name
    address_prefix       = "10.0.8.0/26"
}

resource "azurerm_subnet" "AzureBastionSubnet" {
    name                 = "AzureBastionSubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hubvnet.name
    address_prefix       = "10.0.10.0/27"
}

#CREATE SPOKE VNET AND SUBNETS
# Create virtual network
resource "azurerm_virtual_network" "spokevnet" {
    name                = "spokevnet"
    address_space       = ["10.1.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "websubnet" {
    name                 = "websubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.spokevnet.name
    address_prefix       = "10.1.1.0/24"
}

#CREATE ON PREMISES VNET AND SUBNETS
# Create virtual network
resource "azurerm_virtual_network" "onpremvnet" {
    name                = "onpremvnet"
    address_space       = ["192.168.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "onpremSubnet" {
    name                 = "onpremSubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.onpremvnet.name
    address_prefix       = "192.168.1.0/24"
}
resource "azurerm_subnet" "onpremgatewaysubnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.onpremvnet.name
    address_prefix       = "192.168.10.0/27"
}