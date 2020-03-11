# Configure the Microsoft Azure Provider.
provider "azurerm" {
    version = "=2.0.0"
    features {}
    subscription_id = "Your Azure Subscription ID"
    client_id       = "Your Azure Service Principal App ID"
    client_secret   = "Your Azure Service Principal Client Secret"
    tenant_id       = "Your Azure Tenant ID"
    #service principal information to login 
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "RG-Networking-Demo"
    location = var.location
}
