# -----------------------------------------------------------------------------
# Monitoring Module - Variables
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

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = "devops@edutrack.example.com"
}

variable "frontend_url" {
  description = "URL of the frontend web app for availability testing"
  type        = string
  default     = null
}
