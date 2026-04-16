variable "module_code" {
  description = "Module code; used for tagging only."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the shared platform storage account where containers are created."
  type        = string
}

variable "storage_account_id" {
  description = "Resource ID of the shared platform storage account (for RBAC scoping)."
  type        = string
}

variable "containers" {
  description = "List of blob containers to create on the shared storage account."
  type = list(object({
    name        = string
    access_type = optional(string, "private")
  }))
  default = []
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the module's managed identity to grant blob access. Null skips RBAC."
  type        = string
  default     = null
}

variable "blob_role" {
  description = "Built-in blob role to assign on the storage account. Common: 'Storage Blob Data Reader', 'Storage Blob Data Contributor'."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "grant_blob_delegator" {
  description = "Also assign the 'Storage Blob Delegator' role (needed to mint user-delegation SAS tokens)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
