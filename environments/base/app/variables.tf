variable "env_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "mongodb_connection_string" {
  type = string
  sensitive = true
}