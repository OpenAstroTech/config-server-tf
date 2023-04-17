module "azure_region" {
  source  = "claranet/regions/azurerm"
  azure_region = var.location
}

resource "azurerm_resource_group" "oatconf" {
  name = "rg-${local.name_suffix}"
  location = var.location
}

resource "azurerm_container_app_environment" "oatconf" {
  name                       = "cae-${local.name_suffix}"
  location                   = azurerm_resource_group.oatconf.location
  resource_group_name        = azurerm_resource_group.oatconf.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_container_app" "oatconf" {
  name                         = "ca-${local.name_suffix}"
  container_app_environment_id = azurerm_container_app_environment.oatconf.id
  resource_group_name          = azurerm_resource_group.oatconf.name
  revision_mode                = "Single"

  secret {
    name = "mongo-connection-string"
    value = var.mongodb_connection_string
  }

  template {
    container {
      name   = "config-server"
      image  = "openastrotech/config-server:latest"
      cpu    = "0.25"
      memory = "0.5Gi"

      env {
        name = "MONGO_CONNECTION_STRING"
        secret_name = "mongo-connection-string"
      }
    }
  }

  ingress {
    target_port = 80
    external_enabled = true
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}