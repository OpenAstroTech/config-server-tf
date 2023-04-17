locals {
  name_suffix = join("-", [
    "oatconf",
    "log",
    var.env_name
  ])
}