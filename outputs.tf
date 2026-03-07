###############################################################################
# Secrets
###############################################################################

output "secret_ids" {
  description = "Map of secret IDs to their fully-qualified resource IDs."
  value       = { for k, v in google_secret_manager_secret.this : k => v.id }
}

output "secret_names" {
  description = "Map of secret IDs to their resource names."
  value       = { for k, v in google_secret_manager_secret.this : k => v.name }
}

###############################################################################
# Secret Versions
###############################################################################

output "secret_version_ids" {
  description = "Map of secret version logical names to their fully-qualified resource IDs."
  value       = { for k, v in google_secret_manager_secret_version.this : k => v.id }
}

output "secret_version_names" {
  description = "Map of secret version logical names to their resource names."
  value       = { for k, v in google_secret_manager_secret_version.this : k => v.name }
}

output "secret_version_numbers" {
  description = "Map of secret version logical names to their version numbers."
  value       = { for k, v in google_secret_manager_secret_version.this : k => v.version }
}

###############################################################################
# Project
###############################################################################

output "project_id" {
  description = "The GCP project ID."
  value       = var.project_id
}
