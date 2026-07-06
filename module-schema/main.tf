locals {
  secret_prefix = "saas-mod-${replace(var.module_code, "-", "")}-"
  schema_name   = coalesce(var.schema_name, "module_${replace(var.module_code, "-", "_")}")

  base_tags = merge(var.tags, {
    ModuleCode = var.module_code
    Component  = "module-schema"
  })
}

# Per-module Postgres connection-string secret. The platform stack creates the
# shared Postgres server and exposes the connection string as a remote-state
# output; this module wraps it in a per-module-prefixed KV secret so the
# module's secret-bootstrap pattern picks it up at runtime.
#
# Schema + role creation itself stays at runtime in platform_sdk.ensure_module_schema()
# until we add a Postgres provider here (blocked on Terraform reaching the
# private VNet from CI runners).
resource "azurerm_key_vault_secret" "database_url" {
  provider     = azurerm.kv_writer
  name         = "${local.secret_prefix}database-url"
  value        = var.connection_string
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [value]
  }

  tags = local.base_tags
}
