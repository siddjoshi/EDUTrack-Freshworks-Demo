# -----------------------------------------------------------------------------
# Web App Module - Variables
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location_short" {
  description = "Short form of the Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "app_service_plan_sku" {
  description = "SKU for the App Service Plan"
  type = object({
    tier = string
    size = string
  })
}

variable "frontend_app_name" {
  description = "Name of the frontend web app"
  type        = string
}

variable "backend_app_name" {
  description = "Name of the backend web app"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for VNet integration"
  type        = string
}

variable "key_vault_uri" {
  description = "URI of the Key Vault"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_primary_access_key" {
  description = "Primary access key for the storage account"
  type        = string
  sensitive   = true
}

variable "postgresql_connection_string" {
  description = "Connection string for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "appinsights_connection_string" {
  description = "Connection string for Application Insights"
  type        = string
  sensitive   = true
}

variable "appinsights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  type        = string
  sensitive   = true
}
