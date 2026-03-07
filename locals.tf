locals {
  # Merge common labels with per-secret labels
  secret_labels = {
    for k, v in var.secrets : k => merge(var.labels, v.labels)
  }

  # Flatten IAM bindings for google_secret_manager_secret_iam_member
  secret_iam_members = merge([
    for binding_key, binding in var.secret_iam_bindings : {
      for member in binding.members :
      "${binding_key}/${member}" => {
        secret_id = binding.secret_id
        role      = binding.role
        member    = member
        condition = binding.condition
      }
    }
  ]...)

  # Map of created secret IDs for output
  secret_ids = {
    for k, v in google_secret_manager_secret.this : k => v.id
  }

  # Map of created secret names
  secret_names = {
    for k, v in google_secret_manager_secret.this : k => v.name
  }
}
