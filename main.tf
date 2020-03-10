# Configure the Microsoft Azure Provider.
provider "azurerm" {
    version = "=2.0.0"
    features {}
    subscription_id = "cce01445-8719-4563-b5b7-37b26250b020"
    client_id       = "e779ba7b-619d-4617-a964-66d743f02887"
    client_secret   = "2f053691-cce4-435c-84ee-917e30b84aa8"
    tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    #service principal information to login 
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "RG-Networking-Demo"
    location = var.location
}

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

# create VM in HUB Network
# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "vmhub" {
    name                  = "azmngserver1"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nichub.id]
    size                  = var.vmsize
    admin_username        = var.adminname
    admin_password        = var.adminpwd

    os_disk {
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }

}

# Create network interface
resource "azurerm_network_interface" "nichub" {
    name                      = "azmngserver1-nic01"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "IPConfig1"
        subnet_id                     = azurerm_subnet.managementsubnet.id
        private_ip_address_allocation = "dynamic"
    }
}
#run custom script to setup VM
resource "azurerm_virtual_machine_extension" "exthub" {
  name                 = "hostname1"
  virtual_machine_id   = azurerm_windows_virtual_machine.vmhub.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"

  settings = <<SETTINGS
    {
    "fileUris": ["${var.scriptping}"],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -file enable-icmp.ps1"
    }
SETTINGS
}

# create VM in Onpremises Network
# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "vmop" {
    name                  = "onpremserver1"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nicop.id]
    size                  = var.vmsize
    admin_username        = var.adminname
    admin_password        = var.adminpwd

    os_disk {
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }

}

# Create network interface
resource "azurerm_network_interface" "nicop" {
    name                      = "onpremserver1-nic01"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "IPConfig1"
        subnet_id                     = azurerm_subnet.onpremSubnet.id
        private_ip_address_allocation = "dynamic"
    }
}
#run custom script to setup VM
resource "azurerm_virtual_machine_extension" "extop" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_windows_virtual_machine.vmop.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"

  settings = <<SETTINGS
    {
    "fileUris": ["${var.scriptping}"],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -file enable-icmp.ps1"
    }
SETTINGS
}

# create VM in Spoke Network
# create availability set
resource "azurerm_availability_set" "avset" {
    name = "vmavset-spokevm"
    platform_fault_domain_count = "3"
    platform_update_domain_count = "5" 
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    managed = "true"
}
# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "vmspoke" {
    name                  = "azwsserver${count.index}"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
    size                  = var.vmsize
    admin_username        = var.adminname
    admin_password        = var.adminpwd
    availability_set_id = azurerm_availability_set.avset.id
    count = 2

    os_disk {
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
    name                      = "azwsserver-NIC${count.index}"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg.name
    count = 2

    ip_configuration {
        name                          = "IPConfig1"
        subnet_id                     = azurerm_subnet.websubnet.id
        private_ip_address_allocation = "dynamic"
    }
}
#run custom script to setup VM
resource "azurerm_virtual_machine_extension" "extspoke" {
  name                 = "deploy-iis"
  virtual_machine_id   = element(azurerm_windows_virtual_machine.vmspoke.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"
  count = 2

  settings = <<SETTINGS
    {
    "fileUris": ["${var.scriptiis}"],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -file ./deploy-iis.ps1"
    }
SETTINGS
}
#create log analytics
resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = "netdemo-loganalytics"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
#create network watcher
resource "azurerm_network_watcher" "watcher" {
  name                = "demo-nwwatcher"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
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
#configure Azure Bastion Host
resource "azurerm_public_ip" "bastionpip" {
  name                = "bastionpip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastionhost" {
  name                = "demobastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}
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

#create azure firewall
resource "azurerm_public_ip" "azfirewallpip" {
  name                = "azfirewallpip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "azfirewall" {
  name                = "demoazfirewall"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_virtual_machine_extension.extspoke]

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.azfirewallpip.id
  }
}
resource "azurerm_firewall_application_rule_collection" "azfirewall-apprules" {
  name                = "app-allow-rule-websites"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "allow-microsoft"

    source_addresses = [
      "10.0.2.0/24",
      "10.1.1.0/24",
    ]

    target_fqdns = [
      "*.microsoft.com",
      "*.azure.com",
      "*.windows.net",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }
  }
}
resource "azurerm_firewall_network_rule_collection" "azfirewall-netrules" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "net-allow-rule-dns"

    source_addresses = [
      "10.0.0.0/16",
      "10.1.0.0/16",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "168.63.129.16",
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}

resource "azurerm_firewall_nat_rule_collection" "fd2fwnat" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.azfirewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Dnat"

  rule {
    name = "fw2lbnat"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "80",
    ]
    destination_addresses = [
      "${azurerm_public_ip.azfirewallpip.ip_address}",
    ]
    protocols = [
      "TCP"
    ]
    translated_address = "10.1.1.100"
    translated_port = "80"
  }
}

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

#create front end private loadbalance for web vms on spoke vnet

resource "azurerm_lb" "lbspokeweb" {
  name                = "lbspokeweb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Basic"

  frontend_ip_configuration {
    name                 = "PrivateIPAddress"
    private_ip_address = "10.1.1.100"
    private_ip_address_allocation = "Static"
    subnet_id = azurerm_subnet.websubnet.id
  }
}
resource "azurerm_lb_backend_address_pool" "lb-backendpool" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lbspokeweb.id
  name                = "BackEndAddressPool"
}
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lbspokeweb.id
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PrivateIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb-backendpool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lb_probe.id
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lbspokeweb.id
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}
# create load balancer backend pool association with VM NICs
resource "azurerm_network_interface_backend_address_pool_association" "backendassociation" {
  network_interface_id    = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name   = "IPConfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backendpool.id
  count = 2
  depends_on = [azurerm_virtual_machine_extension.extspoke]
}
#Enable network watcher flow logs
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rg.name
    }
  
    byte_length = 8
}


resource "azurerm_storage_account" "storageaccount" {
  name                     = "petsa${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_network_watcher_flow_log" "watcher-flow-mgmt" {
  network_watcher_name = azurerm_network_watcher.watcher.name
  resource_group_name  = azurerm_resource_group.rg.name

  network_security_group_id = azurerm_network_security_group.nsgmgmt.id
  storage_account_id        = azurerm_storage_account.storageaccount.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.loganalytics.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.loganalytics.location
    workspace_resource_id = azurerm_log_analytics_workspace.loganalytics.id
  }
}
resource "azurerm_network_watcher_flow_log" "watcher-flow-web" {
  network_watcher_name = azurerm_network_watcher.watcher.name
  resource_group_name  = azurerm_resource_group.rg.name

  network_security_group_id = azurerm_network_security_group.nsgweb.id
  storage_account_id        = azurerm_storage_account.storageaccount.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.loganalytics.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.loganalytics.location
    workspace_resource_id = azurerm_log_analytics_workspace.loganalytics.id
  }
}
#create azure front door 
resource "azurerm_frontdoor" "azfrontdoor" {
  name                                         = var.frontdoorname
  location                                     = var.location
  resource_group_name                          = azurerm_resource_group.rg.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "exampleRoutingRule1"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["exampleFrontendEndpoint1"]
    forwarding_configuration {
      forwarding_protocol = "HttpOnly"
      backend_pool_name   = "exampleBackend"
    }
  }

  backend_pool_load_balancing {
    name = "exampleLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "exampleHealthProbeSetting1"
  }

  backend_pool {
    name = "exampleBackend"
    backend {
      host_header = "mytest"
      address     = azurerm_public_ip.azfirewallpip.ip_address
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "exampleLoadBalancingSettings1"
    health_probe_name   = "exampleHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "exampleFrontendEndpoint1"
    host_name                         = "${var.frontdoorname}.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}