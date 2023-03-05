locals {
  available_stages = {
    "dev" : "dev",
    "prod" : "prod"
  }

  stage       = local.available_stages[terraform.workspace]
  name_suffix = "oatconf-${local.stage}"
  location    = "westeurope"
}
