data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "oatconf" {
  name     = "rg-oatconf"
  location = local.location
}

resource "azurerm_cosmosdb_account" "oatconf" {
  name                = "cosmos-acc-oatconf"
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
}

resource "azurerm_log_analytics_workspace" "oatconf" {
  name                = "la-oatconf"
  location            = azurerm_resource_group.oatconf.location
  resource_group_name = azurerm_resource_group.oatconf.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "oatconf" {
  name                = "ai-oatconf"
  location            = azurerm_resource_group.oatconf.location
  resource_group_name = azurerm_resource_group.oatconf.name
  workspace_id        = azurerm_log_analytics_workspace.oatconf.id
  application_type    = "web"
}

resource "azurerm_container_app_environment" "oatconf" {
  name                       = "caenv-oatconf"
  location                   = azurerm_resource_group.oatconf.location
  resource_group_name        = azurerm_resource_group.oatconf.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.oatconf.id
}

resource "azurerm_container_app" "oatconf" {
  name                         = "oatconf"
  container_app_environment_id = azurerm_container_app_environment.oatconf.id
  resource_group_name          = azurerm_resource_group.oatconf.name
  revision_mode                = "Single"

  secret {
    name = "mongo-connection-string"
    value = tostring("${azurerm_cosmosdb_account.oatconf.connection_strings[0]}")
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
