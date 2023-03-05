data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "oatconf" {
  name     = "rg-${local.name_suffix}"
  location = local.location
}

resource "azurerm_cosmosdb_account" "oatconf" {
  name                = "cosmon-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.oatconf.name
  location            = azurerm_resource_group.oatconf.location

  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.2"

  enable_automatic_failover = true

  capabilities {
    name = "EnableServerless"
  }

  capabilities {
    name = "DisableRateLimitingResponses"
  }

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableAggregationPipeline"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = local.location
    failover_priority = 0
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_log_analytics_workspace" "oatconf" {
  name                = "log-${local.name_suffix}"
  location            = azurerm_resource_group.oatconf.location
  resource_group_name = azurerm_resource_group.oatconf.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "oatconf" {
  name                = "appi-${local.name_suffix}"
  location            = azurerm_resource_group.oatconf.location
  resource_group_name = azurerm_resource_group.oatconf.name
  workspace_id        = azurerm_log_analytics_workspace.oatconf.id
  application_type    = "web"
}

resource "azurerm_container_app_environment" "oatconf" {
  name                       = "cae-${local.name_suffix}"
  location                   = azurerm_resource_group.oatconf.location
  resource_group_name        = azurerm_resource_group.oatconf.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.oatconf.id
}

resource "azurerm_container_app" "oatconf" {
  name                         = "ca-${local.name_suffix}"
  container_app_environment_id = azurerm_container_app_environment.oatconf.id
  resource_group_name          = azurerm_resource_group.oatconf.name
  revision_mode                = "Single"

  secret {
    name  = "mongo-connection-string"
    value = tostring("${azurerm_cosmosdb_account.oatconf.connection_strings[0]}")
  }

  secret {
    name  = "appinsights-connection-string"
    value = tostring("${azurerm_application_insights.oatconf.connection_string}")
  }

  template {

    container {
      name   = "config-server"
      image  = "openastrotech/config-server:latest"
      cpu    = "0.25"
      memory = "0.5Gi"

      env {
        name        = "MONGO_CONNECTION_STRING"
        secret_name = "mongo-connection-string"
      }

      env {
        name        = "APPINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection-string"
      }

      liveness_probe {
        transport = "HTTP"
        port      = 80
        path      = "/docs"
      }
    }
  }

  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
