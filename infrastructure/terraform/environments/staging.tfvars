# -----------------------------------------------------------------------------
# EDUTrack - Staging Environment Configuration
# -----------------------------------------------------------------------------

environment    = "staging"
location       = "eastus"
location_short = "eus"
owner          = "EDUTrack Release Team"
cost_center    = "IT-Learning-Staging"

# Network Configuration
vnet_address_space              = "10.1.0.0/16"
webapp_subnet_prefix            = "10.1.1.0/24"
database_subnet_prefix          = "10.1.2.0/24"
private_endpoints_subnet_prefix = "10.1.3.0/24"

# Allow access from corporate IP ranges (update with actual IPs)
allowed_ip_addresses = []

# App Service Configuration - Premium tier for staging (production-like)
app_service_plan_sku = {
  tier = "Premium"
  size = "P1v3"
}

# PostgreSQL Configuration - General Purpose for staging
postgresql_sku_name           = "GP_Standard_D2s_v3"
postgresql_storage_mb         = 65536   # 64 GB
postgresql_backup_retention_days = 14
postgresql_database_name      = "edutrack_staging"

# Note: postgresql_admin_password should be provided via environment variable or tfvars override
# TF_VAR_postgresql_admin_password="your-secure-password"
