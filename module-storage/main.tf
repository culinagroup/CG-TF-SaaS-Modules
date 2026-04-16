resource "azurerm_storage_container" "this" {
  for_each              = { for c in var.containers : c.name => c }
  name                  = each.value.name
  storage_account_name  = var.storage_account_name
  container_access_type = each.value.access_type
}

resource "azurerm_role_assignment" "blob" {
  count                = var.managed_identity_principal_id != null ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = var.blob_role
  principal_id         = var.managed_identity_principal_id
}

resource "azurerm_role_assignment" "blob_delegator" {
  count                = var.managed_identity_principal_id != null && var.grant_blob_delegator ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Delegator"
  principal_id         = var.managed_identity_principal_id
}
