resource "azurerm_resource_group" "log" {
  name = "rg-${local.name_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${local.name_suffix}"
  location            = azurerm_resource_group.log.location
  resource_group_name = azurerm_resource_group.log.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "log" {
  name                = "appi-${local.name_suffix}"
  location            = azurerm_resource_group.log.location
  resource_group_name = azurerm_resource_group.log.name
  workspace_id        = azurerm_log_analytics_workspace.log.id
  application_type    = "web"
}
