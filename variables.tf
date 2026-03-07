###############################################################################
# General
###############################################################################

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

###############################################################################
# Secrets
###############################################################################

variable "secrets" {
  description = <<-EOT
    Map of secrets to create in Secret Manager.
    Key is the secret_id.
    EOT
  type = map(object({
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    # Replication configuration — exactly one must be specified
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

    # Rotation
    rotation = optional(object({
      next_rotation_time = optional(string, null)
      rotation_period    = optional(string, null)
    }), null)

    # TTL — automatic deletion after duration
    ttl = optional(string, null)

    # Expiration — absolute timestamp
    expire_time = optional(string, null)

    # Pub/Sub topic notifications
    topics = optional(list(object({
      name = string
    })), [])

    # Version aliases
    version_aliases = optional(map(string), {})
  }))
  default = {}
}

###############################################################################
# Secret Versions
###############################################################################

variable "secret_versions" {
  description = <<-EOT
    Map of secret versions to create.
    Key is a logical name. secret_id must match a key in var.secrets or be a full resource ID.
    EOT
  type = map(object({
    secret_id   = string
    secret_data = string
    enabled     = optional(bool, true)
    is_secret_data_base64 = optional(bool, false)
  }))
  default   = {}
  sensitive = true
}

###############################################################################
# IAM Bindings
###############################################################################

variable "secret_iam_bindings" {
  description = <<-EOT
    Map of IAM bindings for secrets.
    Key is a logical name.
    EOT
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
