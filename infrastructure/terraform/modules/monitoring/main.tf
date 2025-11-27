# -----------------------------------------------------------------------------
# EDUTrack - Monitoring Module
# Azure Application Insights and Log Analytics
# -----------------------------------------------------------------------------

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-edutrack-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prod" ? 730 : 90  # 2 years for prod, 90 days for others

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-edutrack-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  daily_data_cap_in_gb                  = var.environment == "prod" ? 10 : var.environment == "staging" ? 5 : 2
  daily_data_cap_notifications_disabled = false

  tags = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-edutrack-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "edutrack"

  email_receiver {
    name                    = "DevOps Team"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

# Alert Rule - High Response Time
resource "azurerm_monitor_metric_alert" "response_time" {
  name                = "alert-response-time-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when response time exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.environment == "prod" ? 2000 : 3000  # 2s for prod, 3s for others
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Alert Rule - High Failure Rate
resource "azurerm_monitor_metric_alert" "failure_rate" {
  name                = "alert-failure-rate-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when failure rate exceeds threshold"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.environment == "prod" ? 10 : 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Alert Rule - Exceptions
resource "azurerm_monitor_metric_alert" "exceptions" {
  name                = "alert-exceptions-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when exception count exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.environment == "prod" ? 5 : 20
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Availability Test (Web Test) - Production only
resource "azurerm_application_insights_standard_web_test" "availability" {
  count                   = var.environment == "prod" && var.frontend_url != null ? 1 : 0
  name                    = "webtest-edutrack-availability"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.main.id
  geo_locations           = ["us-ca-sjc-azr", "us-tx-sn1-azr", "us-il-ch1-azr"]
  frequency               = 300  # 5 minutes

  request {
    url = "${var.frontend_url}/health"
  }

  validation_rules {
    expected_status_code = 200
  }

  tags = var.tags
}
