output "connection_string" {
  value = tostring("${azurerm_cosmosdb_account.db.connection_strings[0]}")
  sensitive = true
}