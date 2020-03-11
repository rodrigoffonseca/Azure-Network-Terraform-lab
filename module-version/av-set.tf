# create availability set
resource "azurerm_availability_set" "avset" {
    name = "vmavset-spokevm"
    platform_fault_domain_count = "3"
    platform_update_domain_count = "5" 
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    managed = "true"
}