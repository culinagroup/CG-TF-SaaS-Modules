# CG-TF-SaaS-Modules

Versioned, reusable Terraform modules consumed by the Culina SaaS platform and its modules.
This is the Culina-maintained fork used going forward — pin it, not the upstream repo.

Module repos pin a specific tag:

```hcl
module "app" {
  source = "git::https://github.com/culinagroup/CG-TF-SaaS-Modules.git//module-app?ref=v0.2.0"
  # …
}
```

## Modules

| Module | Purpose |
|---|---|
| `module-app` | Per-module Container App + KV secret shells + standard env-var/health-probe wiring. Folds together the legacy `app-module` and the bespoke `geofence` variant — `application_insights_connection_string` and `http_scale_concurrent_requests` are now first-class inputs. |
| `module-schema` | Per-module Postgres connection-string KV secret. Schema + role creation is currently runtime (via `platform_sdk.ensure_module_schema()`); Terraform side stays narrow until we move schema management up here. |
| `module-storage` | Optional blob container(s) on the shared platform storage account, with RBAC for the module's managed identity. |

## Tagging

Every taggable resource these modules create applies the caller-supplied `tags` map verbatim
(via `merge(var.tags, …)`), so passing the platform's Culina tag set (`BudgetApprover`,
`CostCenter`, `WorkloadName`, `Section`, `BusinessCriticality`, `Environment`, `TechOwner`,
`BusinessOwner`, `ProjectName`, `DrEnabled`, `BackupEnabled`, `Location`) makes module resources
Culina-compliant automatically. The modules add two supplementary keys — `ModuleCode` and
`Component` — for cost/ownership attribution. Tag *values* are owned by the caller (single source
of truth); the modules never construct Culina tags themselves.

Resource naming follows Azure CAF abbreviations keyed off `module_code` (e.g. the Container App is
`ca-saas-mod-<module_code>-<env>`). Region is not embedded in names — it is recorded in the
`Location` tag — so names stay within Azure length limits (see `app_name_override` for the rare
long-code overflow of the 32-char Container App limit).

## Versioning

- Tag each release `vMAJOR.MINOR.PATCH`. Bump MAJOR on breaking variable / behavior changes; consumers pin and upgrade deliberately.
- Keep a CHANGELOG entry per release covering input/output deltas.

## Routing

Front Door / APIM routing for `/api/v1/modules/{code}/*` is **not yet** in this repo — see plan task #9 (`module-routing`). Today routing is implicit via DNS CNAME wildcards on the Container Apps Environment.
