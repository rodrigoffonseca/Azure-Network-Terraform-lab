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