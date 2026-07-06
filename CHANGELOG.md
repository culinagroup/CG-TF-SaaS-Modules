# Changelog

## v0.2.0

Culina-maintained fork (`culinagroup/CG-TF-SaaS-Modules`) — consumers should pin this repo/tag
rather than the upstream `agentic-saas-developments/tf-saas-modules`.

### Tagging (Culina naming & tagging standard)
- Supplementary tag keys emitted by `module-app` and `module-schema` renamed to PascalCase for a
  consistent tag schema: `module_code` → `ModuleCode`, `component` → `Component`.
- No other behaviour change. Every taggable resource continues to apply the caller's `tags` map via
  `merge(var.tags, …)`, so passing the platform's full Culina tag set makes module resources
  compliant with no module-side changes. `module-storage` has no taggable resources (storage
  containers and role assignments do not support tags).
- Naming unchanged: `ca-saas-mod-<code>-<env>` (CAF-structured); region is carried in the
  `Location` tag, not the name.

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
