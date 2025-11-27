# -----------------------------------------------------------------------------
# EDUTrack - Production Environment Configuration
# -----------------------------------------------------------------------------

environment    = "prod"
location       = "eastus"
location_short = "eus"
owner          = "EDUTrack Operations"
cost_center    = "IT-Learning-Prod"

# Network Configuration
vnet_address_space              = "10.2.0.0/16"
webapp_subnet_prefix            = "10.2.1.0/24"
database_subnet_prefix          = "10.2.2.0/24"
private_endpoints_subnet_prefix = "10.2.3.0/24"

# Allow access from corporate IP ranges (update with actual IPs)
allowed_ip_addresses = []

# App Service Configuration - Premium tier for production
app_service_plan_sku = {
  tier = "Premium"
  size = "P2v3"
}

# PostgreSQL Configuration - General Purpose for production
postgresql_sku_name           = "GP_Standard_D4s_v3"
postgresql_storage_mb         = 131072   # 128 GB
postgresql_backup_retention_days = 35
postgresql_database_name      = "edutrack"

# Note: postgresql_admin_password should be provided via environment variable or tfvars override
# TF_VAR_postgresql_admin_password="your-secure-password"
