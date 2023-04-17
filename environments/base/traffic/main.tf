resource "azurerm_resource_group" "tm" {
  name     = "rg-${local.name_suffix}"
  location = var.location
}

resource "azurerm_traffic_manager_profile" "tm" {
  name = "traf-${local.name_suffix}"

  resource_group_name    = azurerm_resource_group.tm
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = var.relative_name
    ttl           = 60
  }
}

resource "azurerm_traffic_manager_external_endpoint" "tm" {
  for_each   = var.targets
  name       = "trafend-"
  profile_id = azurerm_traffic_manager_profile.tm.id
  weight     = 100
  target     = each.value.fqdn
}
