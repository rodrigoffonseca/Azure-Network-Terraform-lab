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