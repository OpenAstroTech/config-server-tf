locals {
  name_suffix = join("-", [
    "oatconf",
    "tm",
    var.env_name
  ])
}