# -----------------------------------------------------------------------------
# EDUTrack - Terraform Outputs
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

# -----------------------------------------------------------------------------
# Web Apps
# -----------------------------------------------------------------------------
output "frontend_webapp_url" {
  description = "URL of the frontend web app"
  value       = module.webapp.frontend_url
}

output "frontend_webapp_name" {
  description = "Name of the frontend web app"
  value       = module.webapp.frontend_name
}

output "backend_webapp_url" {
  description = "URL of the backend API web app"
  value       = module.webapp.backend_url
}

output "backend_webapp_name" {
  description = "Name of the backend API web app"
  value       = module.webapp.backend_name
}

# -----------------------------------------------------------------------------
# PostgreSQL
# -----------------------------------------------------------------------------
output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.postgresql.server_name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.postgresql.server_fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.postgresql.database_name
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------
output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage.primary_blob_endpoint
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.keyvault.key_vault_uri
}

# -----------------------------------------------------------------------------
# Application Insights
# -----------------------------------------------------------------------------
output "application_insights_name" {
  description = "Name of the Application Insights resource"
  value       = module.monitoring.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.monitoring.instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}
