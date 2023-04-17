locals {
  name_suffix = join("-", [
    "oatconf",
    "app",
    module.azure_region.location_short,
    var.env_name
  ])
}