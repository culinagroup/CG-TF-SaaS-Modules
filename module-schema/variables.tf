variable "module_code" {
  description = "Module code (e.g. 'geofence'). The KV secret name becomes 'saas-mod-{code}-database-url'."
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID."
  type        = string
}

variable "schema_name" {
  description = "Postgres schema name owned by this module. Defaults to 'module_{code-with-underscores}'. Schema/role creation itself currently happens at runtime via platform_sdk.ensure_module_schema()."
  type        = string
  default     = null
}

variable "connection_string" {
  description = "Full Postgres connection string (with credentials) — fetched from the platform stack and passed in. Used as the KV secret value."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
