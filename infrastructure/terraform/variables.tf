# -----------------------------------------------------------------------------
# EDUTrack - Terraform Variables
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------
variable "environment" {
  description = "Environment name (dev, test, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short form of the Azure region (e.g., eus for eastus)"
  type        = string
  default     = "eus"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "EDUTrack Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT-Learning"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "webapp_subnet_prefix" {
  description = "Address prefix for the web app subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "database_subnet_prefix" {
  description = "Address prefix for the database subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_endpoints_subnet_prefix" {
  description = "Address prefix for private endpoints subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access resources (for Key Vault and Storage)"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# App Service Configuration
# -----------------------------------------------------------------------------
variable "app_service_plan_sku" {
  description = "SKU for the App Service Plan"
  type = object({
    tier = string
    size = string
  })
  default = {
    tier = "Standard"
    size = "S1"
  }
}

# -----------------------------------------------------------------------------
# PostgreSQL Configuration
# -----------------------------------------------------------------------------
variable "postgresql_admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "edutrackadmin"
  sensitive   = true
}

variable "postgresql_admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.postgresql_admin_password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}

variable "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "edutrack"
}

variable "postgresql_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768  # 32 GB
}

variable "postgresql_backup_retention_days" {
  description = "Backup retention days for PostgreSQL"
  type        = number
  default     = 7
}
