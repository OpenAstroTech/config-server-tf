module "env" {
  source = "../base"

  env_name = "dev"

  locations = [
    "westeurope",
    "westus"
  ]
}
