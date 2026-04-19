locals {
  app_name      = coalesce(var.app_name_override, "ca-saas-mod-${var.module_code}-${var.environment}")
  secret_prefix = "saas-mod-${replace(var.module_code, "-", "")}-"
  # On a fresh ACR, the per-module image hasn't been pushed yet, so the `:init`
  # tag doesn't resolve and Container Apps fails revision provisioning with
  # MANIFEST_UNKNOWN. Fall back to a public placeholder; the lifecycle block
  # on the container app ignores image changes, so deploy.yml's
  # `az containerapp update --image ...` won't be reverted by a later apply.
  placeholder_image = "mcr.microsoft.com/k8se/quickstart:latest"
  image             = var.image != "" ? var.image : local.placeholder_image

  base_tags = merge(var.tags, {
    module_code = var.module_code
    component   = "module"
  })

  # Whether to attach the App Insights env block. We wrap the null-check in
  # `nonsensitive()` because deriving anything from the sensitive var taints
  # it as sensitive — and Terraform rejects sensitive values in for_each.
  # The boolean (is it null or not) doesn't leak the secret itself.
  app_insights_env = nonsensitive(var.application_insights_connection_string != null) ? toset(["enabled"]) : toset([])
}

resource "azurerm_key_vault_secret" "extra" {
  for_each     = toset(var.extra_secrets)
  name         = "${local.secret_prefix}${each.value}"
  value        = "placeholder-set-out-of-band"
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [value]
  }

  tags = local.base_tags
}

resource "azurerm_container_app" "module" {
  name                         = local.app_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = "Single"

  tags = local.base_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  registry {
    server   = var.container_registry_login_server
    identity = var.managed_identity_id
  }

  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "module"
      image  = local.image
      cpu    = var.cpu
      memory = var.memory

      env {
        name  = "MODULE_CODE"
        value = var.module_code
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      env {
        name  = "SECRET_PROVIDER"
        value = "azure"
      }
      env {
        name  = "SECRET_PROVIDER_VAULT_URL"
        value = var.key_vault_uri
      }
      env {
        name  = "SECRET_PROVIDER_PREFIX"
        value = local.secret_prefix
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = var.managed_identity_client_id
      }
      env {
        name  = "PORT"
        value = "8080"
      }

      dynamic "env" {
        for_each = local.app_insights_env
        content {
          name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
          value = var.application_insights_connection_string
        }
      }

      dynamic "env" {
        for_each = { for v in var.extra_env_vars : v.name => v.value }
        content {
          name  = env.key
          value = env.value
        }
      }

      liveness_probe {
        transport               = "HTTP"
        port                    = 8080
        path                    = "/health/live"
        initial_delay           = 5
        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = 8080
        path                    = "/health/ready"
        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
      }

      startup_probe {
        transport               = "HTTP"
        port                    = 8080
        path                    = "/health/startup"
        interval_seconds        = 5
        timeout                 = 3
        failure_count_threshold = 10
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.http_scale_concurrent_requests != null ? [var.http_scale_concurrent_requests] : []
      content {
        name                = "http-scaling"
        concurrent_requests = tostring(http_scale_rule.value)
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}
