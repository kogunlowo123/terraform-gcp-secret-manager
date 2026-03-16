variable "project_id" {
  description = "The GCP project ID where Secret Manager resources will be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "labels" {
  description = "Common labels to apply to all secrets."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of secrets to create in Secret Manager, keyed by secret_id."
  type = map(object({
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    replication = object({
      auto = optional(object({
        customer_managed_encryption = optional(object({
          kms_key_name = string
        }), null)
      }), null)
      user_managed = optional(object({
        replicas = list(object({
          location = string
          customer_managed_encryption = optional(object({
            kms_key_name = string
          }), null)
        }))
      }), null)
    })

    rotation = optional(object({
      next_rotation_time = optional(string, null)
      rotation_period    = optional(string, null)
    }), null)

    ttl         = optional(string, null)
    expire_time = optional(string, null)

    topics = optional(list(object({
      name = string
    })), [])

    version_aliases = optional(map(string), {})
  }))
  default = {}
}

variable "secret_versions" {
  description = "Map of secret versions to create, keyed by logical name."
  type = map(object({
    secret_id             = string
    secret_data           = string
    enabled               = optional(bool, true)
    is_secret_data_base64 = optional(bool, false)
  }))
  default   = {}
  sensitive = true
}

variable "secret_iam_bindings" {
  description = "Map of IAM bindings for secrets, keyed by logical name."
  type = map(object({
    secret_id = string
    role      = string
    members   = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.secret_iam_bindings :
      contains([
        "roles/secretmanager.secretAccessor",
        "roles/secretmanager.secretVersionAdder",
        "roles/secretmanager.secretVersionManager",
        "roles/secretmanager.admin",
        "roles/secretmanager.viewer",
        "roles/owner",
        "roles/editor",
        "roles/viewer",
      ], v.role)
    ])
    error_message = "Role must be a valid Secret Manager IAM role."
  }
}
