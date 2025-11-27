# -----------------------------------------------------------------------------
# Web App Module - Outputs
# -----------------------------------------------------------------------------

output "frontend_url" {
  description = "URL of the frontend web app"
  value       = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

output "frontend_name" {
  description = "Name of the frontend web app"
  value       = azurerm_linux_web_app.frontend.name
}

output "frontend_principal_id" {
  description = "Principal ID of the frontend web app managed identity"
  value       = azurerm_linux_web_app.frontend.identity[0].principal_id
}

output "frontend_tenant_id" {
  description = "Tenant ID of the frontend web app managed identity"
  value       = azurerm_linux_web_app.frontend.identity[0].tenant_id
}

output "backend_url" {
  description = "URL of the backend API web app"
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "backend_name" {
  description = "Name of the backend API web app"
  value       = azurerm_linux_web_app.backend.name
}

output "backend_principal_id" {
  description = "Principal ID of the backend web app managed identity"
  value       = azurerm_linux_web_app.backend.identity[0].principal_id
}

output "backend_tenant_id" {
  description = "Tenant ID of the backend web app managed identity"
  value       = azurerm_linux_web_app.backend.identity[0].tenant_id
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.main.id
}
