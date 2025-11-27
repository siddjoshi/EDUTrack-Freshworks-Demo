# -----------------------------------------------------------------------------
# EDUTrack - Azure Infrastructure with Terraform
# Main configuration file
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # Pin to 3.x minor version for stability while allowing patch updates
      # Review and update when upgrading to 4.x
      version = ">= 3.85.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }

  # Backend configuration for remote state storage
  # Uncomment and configure for production use
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstateedutrack"
  #   container_name       = "tfstate"
  #   key                  = "edutrack.terraform.tfstate"
  # }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Generate random suffix for globally unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local variables for resource naming
locals {
  resource_suffix = random_string.suffix.result
  common_tags = {
    Project     = "EDUTrack"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-edutrack-${var.environment}-${var.location_short}"
  location = var.location

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Virtual Network (for private endpoints and network isolation)
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet-edutrack-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_address_space]

  tags = local.common_tags
}

resource "azurerm_subnet" "webapp" {
  name                 = "snet-webapp"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.webapp_subnet_prefix]

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "database" {
  name                 = "snet-database"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.database_subnet_prefix]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_endpoints_subnet_prefix]
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "postgresql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  resource_group_name   = azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# -----------------------------------------------------------------------------
# Application Insights Module (moved before Key Vault for dependency)
# -----------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  location_short      = var.location_short
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Key Vault Module
# -----------------------------------------------------------------------------
module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  location_short      = var.location_short
  resource_suffix     = local.resource_suffix
  tags                = local.common_tags

  # Network configuration
  virtual_network_id    = azurerm_virtual_network.main.id
  subnet_id             = azurerm_subnet.private_endpoints.id
  allowed_ip_addresses  = var.allowed_ip_addresses

  # Monitoring
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  depends_on = [module.monitoring]
}

# -----------------------------------------------------------------------------
# Storage Account Module
# -----------------------------------------------------------------------------
module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  location_short      = var.location_short
  resource_suffix     = local.resource_suffix
  tags                = local.common_tags

  # Network configuration
  virtual_network_id    = azurerm_virtual_network.main.id
  subnet_id             = azurerm_subnet.private_endpoints.id
  allowed_ip_addresses  = var.allowed_ip_addresses
}

# -----------------------------------------------------------------------------
# PostgreSQL Module
# -----------------------------------------------------------------------------
module "postgresql" {
  source = "./modules/postgresql"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  location_short      = var.location_short
  resource_suffix     = local.resource_suffix
  tags                = local.common_tags

  # Database configuration
  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password
  database_name          = var.postgresql_database_name
  sku_name               = var.postgresql_sku_name
  storage_mb             = var.postgresql_storage_mb
  backup_retention_days  = var.postgresql_backup_retention_days

  # Network configuration
  delegated_subnet_id = azurerm_subnet.database.id
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgresql]
}

# Store PostgreSQL connection string in Key Vault
resource "azurerm_key_vault_secret" "postgresql_connection_string" {
  name         = "postgresql-connection-string"
  value        = module.postgresql.connection_string
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault, module.postgresql]
}

# Store Application Insights connection string in Key Vault
resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  name         = "appinsights-connection-string"
  value        = module.monitoring.connection_string
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault, module.monitoring]
}

# -----------------------------------------------------------------------------
# Web App Module (Frontend and Backend)
# -----------------------------------------------------------------------------
module "webapp" {
  source = "./modules/webapp"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  location_short      = var.location_short
  tags                = local.common_tags

  # App Service Plan configuration
  app_service_plan_sku = var.app_service_plan_sku

  # Frontend configuration
  frontend_app_name = "app-edutrack-web-${var.environment}-${var.location_short}"

  # Backend configuration
  backend_app_name = "app-edutrack-api-${var.environment}-${var.location_short}"

  # Network configuration
  subnet_id = azurerm_subnet.webapp.id

  # Application settings
  key_vault_uri                      = module.keyvault.key_vault_uri
  storage_account_name               = module.storage.storage_account_name
  storage_primary_access_key         = module.storage.primary_access_key
  postgresql_connection_string       = module.postgresql.connection_string
  appinsights_connection_string      = module.monitoring.connection_string
  appinsights_instrumentation_key    = module.monitoring.instrumentation_key

  depends_on = [module.keyvault, module.storage, module.postgresql, module.monitoring]
}

# Grant Web Apps access to Key Vault
resource "azurerm_key_vault_access_policy" "frontend_app" {
  key_vault_id = module.keyvault.key_vault_id
  tenant_id    = module.webapp.frontend_tenant_id
  object_id    = module.webapp.frontend_principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [module.keyvault, module.webapp]
}

resource "azurerm_key_vault_access_policy" "backend_app" {
  key_vault_id = module.keyvault.key_vault_id
  tenant_id    = module.webapp.backend_tenant_id
  object_id    = module.webapp.backend_principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [module.keyvault, module.webapp]
}
