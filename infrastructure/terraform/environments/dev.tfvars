# -----------------------------------------------------------------------------
# EDUTrack - Development Environment Configuration
# -----------------------------------------------------------------------------

environment    = "dev"
location       = "eastus"
location_short = "eus"
owner          = "EDUTrack Dev Team"
cost_center    = "IT-Learning-Dev"

# Network Configuration
vnet_address_space              = "10.0.0.0/16"
webapp_subnet_prefix            = "10.0.1.0/24"
database_subnet_prefix          = "10.0.2.0/24"
private_endpoints_subnet_prefix = "10.0.3.0/24"

# Allow access from corporate IP ranges (update with actual IPs)
allowed_ip_addresses = []

# App Service Configuration - Basic tier for dev
app_service_plan_sku = {
  tier = "Standard"
  size = "S1"
}

# PostgreSQL Configuration - Burstable tier for dev
postgresql_sku_name           = "B_Standard_B1ms"
postgresql_storage_mb         = 32768   # 32 GB
postgresql_backup_retention_days = 7
postgresql_database_name      = "edutrack_dev"

# Note: postgresql_admin_password should be provided via environment variable or tfvars override
# TF_VAR_postgresql_admin_password="your-secure-password"
