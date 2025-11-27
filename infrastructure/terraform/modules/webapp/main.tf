# -----------------------------------------------------------------------------
# EDUTrack - Web App Module
# Azure App Service for Frontend and Backend
# -----------------------------------------------------------------------------

# Local variables for SKU mapping
locals {
  sku_tier_prefix = {
    "Free"     = "F"
    "Shared"   = "D"
    "Basic"    = "B"
    "Standard" = "S"
    "Premium"  = "P"
    "PremiumV2" = "P"
    "PremiumV3" = "P"
  }
  sku_prefix = lookup(local.sku_tier_prefix, var.app_service_plan_sku.tier, "S")
  sku_size   = replace(var.app_service_plan_sku.size, "S", "")
  sku_name   = "${local.sku_prefix}${local.sku_size}"
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "plan-edutrack-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = local.sku_name

  tags = var.tags
}

# Frontend Web App (React/Static Web App)
resource "azurerm_linux_web_app" "frontend" {
  name                = var.frontend_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on                = var.app_service_plan_sku.tier != "Free" && var.app_service_plan_sku.tier != "Shared"
    ftps_state               = "Disabled"
    minimum_tls_version      = "1.2"
    http2_enabled            = true
    vnet_route_all_enabled   = true

    application_stack {
      node_version = "20-lts"
    }

    # CORS configuration - backend URL is set dynamically
    # In production, this should be restricted to specific trusted domains
    cors {
      allowed_origins     = var.environment == "prod" ? ["https://${var.frontend_app_name}.azurewebsites.net"] : ["*"]
      support_credentials = var.environment == "prod"
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION"                = "~20"
    "APPINSIGHTS_INSTRUMENTATIONKEY"              = var.appinsights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"       = var.appinsights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"  = "~3"
    "REACT_APP_API_URL"                           = "https://${var.backend_app_name}.azurewebsites.net"
    "REACT_APP_ENVIRONMENT"                       = var.environment
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = var.subnet_id

  tags = var.tags
}

# Backend Web App (Python FastAPI)
resource "azurerm_linux_web_app" "backend" {
  name                = var.backend_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on                = var.app_service_plan_sku.tier != "Free" && var.app_service_plan_sku.tier != "Shared"
    ftps_state               = "Disabled"
    minimum_tls_version      = "1.2"
    http2_enabled            = true
    vnet_route_all_enabled   = true

    application_stack {
      python_version = "3.11"
    }

    cors {
      allowed_origins     = ["https://${var.frontend_app_name}.azurewebsites.net"]
      support_credentials = true
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"              = var.appinsights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"       = var.appinsights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"  = "~3"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"              = "true"
    "ENABLE_ORYX_BUILD"                           = "true"
    "ENVIRONMENT"                                 = var.environment
    "KEY_VAULT_URI"                               = var.key_vault_uri
    "AZURE_STORAGE_ACCOUNT_NAME"                  = var.storage_account_name
    "AZURE_STORAGE_ACCESS_KEY"                    = var.storage_primary_access_key
    "DATABASE_URL"                                = var.postgresql_connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = var.subnet_id

  tags = var.tags
}

# Deployment slot for blue-green deployments (Backend - Staging only and above)
resource "azurerm_linux_web_app_slot" "backend_staging" {
  count          = var.environment != "dev" && var.environment != "test" ? 1 : 0
  name           = "staging"
  app_service_id = azurerm_linux_web_app.backend.id
  https_only     = true

  site_config {
    always_on                = var.app_service_plan_sku.tier != "Free" && var.app_service_plan_sku.tier != "Shared"
    ftps_state               = "Disabled"
    minimum_tls_version      = "1.2"
    http2_enabled            = true

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"              = var.appinsights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"       = var.appinsights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"  = "~3"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"              = "true"
    "ENABLE_ORYX_BUILD"                           = "true"
    "ENVIRONMENT"                                 = "${var.environment}-staging"
    "KEY_VAULT_URI"                               = var.key_vault_uri
    "AZURE_STORAGE_ACCOUNT_NAME"                  = var.storage_account_name
    "AZURE_STORAGE_ACCESS_KEY"                    = var.storage_primary_access_key
    "DATABASE_URL"                                = var.postgresql_connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Auto-scale settings for production
resource "azurerm_monitor_autoscale_setting" "webapp" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "autoscale-edutrack-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id

  profile {
    name = "default"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.tags
}
