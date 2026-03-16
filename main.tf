resource "google_secret_manager_secret" "this" {
  for_each = var.secrets

  secret_id   = each.key
  labels      = merge(var.labels, each.value.labels)
  annotations = each.value.annotations
  project     = var.project_id
  ttl         = each.value.ttl
  expire_time = each.value.expire_time

  version_aliases = each.value.version_aliases

  replication {
    dynamic "auto" {
      for_each = each.value.replication.auto != null ? [each.value.replication.auto] : []
      content {
        dynamic "customer_managed_encryption" {
          for_each = auto.value.customer_managed_encryption != null ? [auto.value.customer_managed_encryption] : []
          content {
            kms_key_name = customer_managed_encryption.value.kms_key_name
          }
        }
      }
    }

    dynamic "user_managed" {
      for_each = each.value.replication.user_managed != null ? [each.value.replication.user_managed] : []
      content {
        dynamic "replicas" {
          for_each = user_managed.value.replicas
          content {
            location = replicas.value.location

            dynamic "customer_managed_encryption" {
              for_each = replicas.value.customer_managed_encryption != null ? [replicas.value.customer_managed_encryption] : []
              content {
                kms_key_name = customer_managed_encryption.value.kms_key_name
              }
            }
          }
        }
      }
    }
  }

  dynamic "rotation" {
    for_each = each.value.rotation != null ? [each.value.rotation] : []
    content {
      next_rotation_time = rotation.value.next_rotation_time
      rotation_period    = rotation.value.rotation_period
    }
  }

  dynamic "topics" {
    for_each = each.value.topics
    content {
      name = topics.value.name
    }
  }
}

resource "google_secret_manager_secret_version" "this" {
  for_each = var.secret_versions

  secret      = each.value.secret_id
  secret_data = each.value.is_secret_data_base64 ? base64decode(each.value.secret_data) : each.value.secret_data
  enabled     = each.value.enabled

  depends_on = [google_secret_manager_secret.this]
}

resource "google_secret_manager_secret_iam_member" "this" {
  for_each = merge([
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

  secret_id = each.value.secret_id
  role      = each.value.role
  member    = each.value.member
  project   = var.project_id

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
