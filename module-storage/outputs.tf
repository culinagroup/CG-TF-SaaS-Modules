output "container_names" {
  description = "Names of the created blob containers."
  value       = [for c in azurerm_storage_container.this : c.name]
}
