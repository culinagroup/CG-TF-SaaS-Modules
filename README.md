# tf-saas-modules

Versioned, reusable Terraform modules consumed by the SaaS platform and its modules.

Module repos pin a specific tag:

```hcl
module "app" {
  source = "git::https://github.com/BlackRifleCoE/tf-saas-modules.git//module-app?ref=v0.1.0"
  # …
}
```

## Modules

| Module | Purpose |
|---|---|
| `module-app` | Per-module Container App + KV secret shells + standard env-var/health-probe wiring. Folds together the legacy `app-module` and the bespoke `geofence` variant — `application_insights_connection_string` and `http_scale_concurrent_requests` are now first-class inputs. |
| `module-schema` | Per-module Postgres connection-string KV secret. Schema + role creation is currently runtime (via `platform_sdk.ensure_module_schema()`); Terraform side stays narrow until we move schema management up here. |
| `module-storage` | Optional blob container(s) on the shared platform storage account, with RBAC for the module's managed identity. |

## Versioning

- Tag each release `vMAJOR.MINOR.PATCH`. Bump MAJOR on breaking variable / behavior changes; consumers pin and upgrade deliberately.
- Keep a CHANGELOG entry per release covering input/output deltas.

## Routing

Front Door / APIM routing for `/api/v1/modules/{code}/*` is **not yet** in this repo — see plan task #9 (`module-routing`). Today routing is implicit via DNS CNAME wildcards on the Container Apps Environment.
