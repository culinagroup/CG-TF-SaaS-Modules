# Changelog

## v0.1.0 (unreleased)

Initial extraction from `geofence/terraform/modules/`.

### `module-app`
- Folded the bespoke `geofence` module into the generic `app-module`. New first-class inputs:
  - `application_insights_connection_string` — emits `APPLICATIONINSIGHTS_CONNECTION_STRING` when set.
  - `http_scale_concurrent_requests` — adds an HTTP scale rule when set.
- Removed the `database_strategy` input and the `module_db_url` resource. The per-module DB connection-string secret is now owned exclusively by `module-schema` to avoid double-creation. Modules without a database simply omit `module-schema`.

### `module-schema`
- New module. Owns the `saas-mod-{code}-database-url` KV secret. Schema + role creation in Postgres remains a runtime responsibility of `platform_sdk.ensure_module_schema()` until Terraform can reach the private VNet from CI runners.

### `module-storage`
- New module. Provisions blob containers on the shared platform storage account and assigns blob RBAC (and optionally `Storage Blob Delegator`) to a module's managed identity.
