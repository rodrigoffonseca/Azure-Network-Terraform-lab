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
