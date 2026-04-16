variable "module_code" {
  description = "Module code (e.g. 'geofence'). Used for naming and the KV secret prefix."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.module_code))
    error_message = "module_code must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)."
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group containing the Container Apps environment."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "container_app_environment_id" {
  description = "Container Apps environment resource ID."
  type        = string
}

variable "container_registry_login_server" {
  description = "ACR login server FQDN (e.g. crsaasprod.azurecr.io)."
  type        = string
}

variable "managed_identity_id" {
  description = "User-assigned managed identity resource ID for the Container App."
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID of the user-assigned managed identity."
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID where module secrets are stored."
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI (https://…vault.azure.net/)."
  type        = string
}

variable "image" {
  description = "Full container image reference. Empty string substitutes a placeholder ':init' tag — CD overwrites on first deploy."
  type        = string
  default     = ""
}

variable "cpu" {
  description = "CPU allocation."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocation (e.g. '0.5Gi', '2Gi')."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum replicas. Set ≥1 to avoid cold starts."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum replicas."
  type        = number
  default     = 3
}

variable "http_scale_concurrent_requests" {
  description = "HTTP concurrency threshold for autoscaling. Null disables the scale rule (Container Apps default scaling applies)."
  type        = number
  default     = null
}

variable "application_insights_connection_string" {
  description = "App Insights connection string. Null omits the env var."
  type        = string
  default     = null
  sensitive   = true
}

variable "extra_env_vars" {
  description = "Additional plaintext env vars."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "extra_secrets" {
  description = "Additional Key Vault secrets to provision (placeholder values; populate out-of-band). Names are suffixes appended to the module's secret prefix — e.g. 'header-signing-key' becomes 'saas-mod-{code}-header-signing-key'."
  type        = list(string)
  default     = []
}

variable "app_name_override" {
  description = "Override the computed Container App name. Use when 'ca-saas-mod-{module_code}-{environment}' would exceed Azure's 32-char limit."
  type        = string
  default     = null

  validation {
    condition     = var.app_name_override == null || can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.app_name_override))
    error_message = "app_name_override must be 2-32 chars, lowercase alphanumeric + hyphens."
  }
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
