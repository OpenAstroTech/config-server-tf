module "db" {
  source = "./db"
  
  env_name = var.env_name
  locations = var.locations
}

module "log" {
  source = "./log"

  env_name = var.env_name
  location = var.locations[0]
}

module "app" {
  for_each = toset(var.locations)
  source = "./app"

  env_name = var.env_name
  location = each.value

  mongodb_connection_string = module.db.connection_string

  log_analytics_workspace_id = module.log.log_analytics_workspace_id
}

module "traffic" {
  source = "./traffic"

  env_name = var.env_name
  targets = [
    for app in module.app : app.latest_revision_fqdn
  ]
}