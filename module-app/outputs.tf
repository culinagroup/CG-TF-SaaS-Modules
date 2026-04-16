output "container_app_name" {
  description = "Name of the Container App resource."
  value       = azurerm_container_app.module.name
}

output "container_app_id" {
  description = "Resource ID of the Container App."
  value       = azurerm_container_app.module.id
}

output "container_app_fqdn" {
  description = "FQDN of the Container App (internal ingress)."
  value       = azurerm_container_app.module.ingress[0].fqdn
}

output "secret_prefix" {
  description = "Key Vault secret-name prefix used by this module (e.g. 'saas-mod-geofence-')."
  value       = local.secret_prefix
}

output "extra_secret_names" {
  description = "Map of suffix → full KV secret name for extra secrets."
  value       = { for k, v in azurerm_key_vault_secret.extra : k => v.name }
}
