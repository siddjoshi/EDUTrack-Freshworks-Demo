# -----------------------------------------------------------------------------
# EDUTrack - Storage Account Module
# Azure Blob Storage for documents and media
# -----------------------------------------------------------------------------

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "stedutrack${var.environment}${var.resource_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.environment == "prod" ? "Standard" : "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  https_traffic_only_enabled      = true

  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }

    container_delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }

    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT", "DELETE"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  network_rules {
    default_action             = var.environment == "prod" ? "Deny" : "Allow"
    ip_rules                   = var.allowed_ip_addresses
    virtual_network_subnet_ids = []
    bypass                     = ["AzureServices", "Logging", "Metrics"]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Storage Container for Documents
resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Container for Training Content
resource "azurerm_storage_container" "training_content" {
  name                  = "training-content"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Container for User Uploads
resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Container for Backups
resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Local variables for compliance retention periods
locals {
  # 7 years in days for compliance retention (GDPR, ISO 27001)
  compliance_retention_days = 2555  # 7 * 365 = 2555 days
}

# Lifecycle Management Policy
resource "azurerm_storage_management_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "archive-old-documents"
    enabled = true
    filters {
      prefix_match = ["documents/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 90
        tier_to_archive_after_days_since_modification_greater_than = 365
        delete_after_days_since_modification_greater_than          = local.compliance_retention_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 90
      }
    }
  }

  rule {
    name    = "cleanup-temp-uploads"
    enabled = true
    filters {
      prefix_match = ["uploads/temp/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }
}

# Private Endpoint for Storage (Production only)
resource "azurerm_private_endpoint" "storage" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "pe-storage-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "storage-privatelink"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = var.tags
}
