/* #create network security groups Bastion Subnet
resource "azurerm_network_security_group" "nsgbastion" {
  name                = "nsg_azurebastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "bastion-in-allow" {
  name                        = "bastion-in-allow"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}
resource "azurerm_network_security_rule" "bastion-control-in-allow4443" {
  name                        = "bastion-in-allow"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "4443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}
resource "azurerm_network_security_rule" "bastion-control-in-allow443" {
  name                        = "bastion-in-allow"
  priority                    = 125
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range     = "443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}

resource "azurerm_network_security_rule" "bastion-in-deny" {
  name                        = "bastion-in-deny"
  priority                    = 900
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}
resource "azurerm_network_security_rule" "bastion-vnet-out-allowssh" {
  name                        = "bastion-vnet-out-allowssh"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}
resource "azurerm_network_security_rule" "bastion-vnet-out-allowrdp" {
  name                        = "bastion-vnet-out-allowrdp"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range     = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}
resource "azurerm_network_security_rule" "bastion-azure-out-allow" {
  name                        = "bastion-vnet-out-allow"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgbastion.name
}

resource "azurerm_subnet_network_security_group_association" "nsgbastionsubnet" {
  subnet_id                 = azurerm_subnet.AzureBastionSubnet.id
  network_security_group_id = azurerm_network_security_group.nsgbastion.id
}
 */
 #create network security groups Management Subnet
resource "azurerm_network_security_group" "nsgmgmt" {
  name                = "nsg_mgmt"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "managment-in-allow_ssh" {
  name                        = "managment-in-allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgmgmt.name
}
resource "azurerm_network_security_rule" "managment-in-allow_rdp" {
  name                        = "managment-in-allow_rdp"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgmgmt.name
}
resource "azurerm_network_security_rule" "managment-in-allow_icmp" {
  name                        = "managment-in-allow_icmp"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgmgmt.name
}
resource "azurerm_subnet_network_security_group_association" "nsgmgmtsubnet" {
  subnet_id                 = azurerm_subnet.managementsubnet.id
  network_security_group_id = azurerm_network_security_group.nsgmgmt.id
  depends_on = [azurerm_virtual_machine_extension.extspoke]
}
#create network security groups Web Subnet
resource "azurerm_network_security_group" "nsgweb" {
  name                = "nsg_web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "web-in-allow_ssh" {
  name                        = "web-in-allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgweb.name
}
resource "azurerm_network_security_rule" "web-in-allow_rdp" {
  name                        = "web-in-allow_rdp"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgweb.name
}
resource "azurerm_network_security_rule" "web-in-allow_http" {
  name                        = "web-in-allow_http"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgweb.name
}
resource "azurerm_network_security_rule" "web-in-allow_https" {
  name                        = "web-in-allow_https"
  priority                    = 125
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgweb.name
}
resource "azurerm_network_security_rule" "web-in-allow_icmp" {
  name                        = "web-in-allow_icmp"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgweb.name
}

resource "azurerm_subnet_network_security_group_association" "nswebsubnet" {
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.nsgweb.id
  depends_on = [azurerm_virtual_machine_extension.extspoke]
}