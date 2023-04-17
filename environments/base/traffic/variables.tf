variable "env_name" {
  type = string
}

variable "dns_relative_name" {
  type = string
}

variable "targets" {
  type = list(object({
    fqdn = string,
    location_short = string
  }))
}
