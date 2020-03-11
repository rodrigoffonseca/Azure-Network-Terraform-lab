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