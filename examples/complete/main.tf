###############################################################################
# Complete Example — All Secret Manager Features
###############################################################################

module "secrets" {
  source = "../../"

  project_id = "my-gcp-project"

  labels = {
    team        = "platform"
    environment = "production"
    managed_by  = "terraform"
  }

  secrets = {
    # High-sensitivity secret with CMEK, rotation, and notifications
    "database-credentials" = {
      labels = {
        sensitivity = "critical"
        system      = "database"
      }
      annotations = {
        "owner" = "platform-team"
        "docs"  = "https://wiki.example.com/secrets/database"
      }
      replication = {
        user_managed = {
          replicas = [
            {
              location = "us-central1"
              customer_managed_encryption = {
                kms_key_name = "projects/my-gcp-project/locations/us-central1/keyRings/secrets/cryptoKeys/secrets-key"
              }
            },
            {
              location = "us-east1"
              customer_managed_encryption = {
                kms_key_name = "projects/my-gcp-project/locations/us-east1/keyRings/secrets/cryptoKeys/secrets-key"
              }
            },
            {
              location = "europe-west1"
              customer_managed_encryption = {
                kms_key_name = "projects/my-gcp-project/locations/europe-west1/keyRings/secrets/cryptoKeys/secrets-key"
              }
            },
          ]
        }
      }
      rotation = {
        rotation_period    = "2592000s"
        next_rotation_time = "2025-02-01T00:00:00Z"
      }
      topics = [
        { name = "projects/my-gcp-project/topics/secret-events" },
        { name = "projects/my-gcp-project/topics/audit-events" },
      ]
      version_aliases = {
        "current"  = "1"
        "previous" = "1"
      }
    }

    # Auto-replicated secret with CMEK
    "api-gateway-key" = {
      labels = {
        sensitivity = "high"
        system      = "api-gateway"
      }
      replication = {
        auto = {
          customer_managed_encryption = {
            kms_key_name = "projects/my-gcp-project/locations/global/keyRings/secrets/cryptoKeys/secrets-key"
          }
        }
      }
      topics = [
        { name = "projects/my-gcp-project/topics/secret-events" },
      ]
    }

    # Simple auto-replicated secret
    "feature-flags" = {
      labels = {
        sensitivity = "low"
        system      = "config"
      }
      replication = {
        auto = {}
      }
    }

    # Secret with TTL for temporary use
    "temp-migration-key" = {
      labels = {
        purpose = "migration"
      }
      replication = {
        auto = {}
      }
      ttl = "2592000s"
    }

    # Secret with expiration timestamp
    "contractor-access-token" = {
      labels = {
        purpose = "contractor-access"
      }
      replication = {
        auto = {}
      }
      expire_time = "2025-06-30T00:00:00Z"
    }
  }

  # ---------- Secret Versions ----------
  secret_versions = {
    "database-credentials-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/database-credentials"
      secret_data = "{\"username\":\"app_user\",\"password\":\"secure-password-v1\",\"host\":\"10.0.0.5\"}"
    }
    "api-gateway-key-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/api-gateway-key"
      secret_data = "gw-key-abc123def456"
    }
    "feature-flags-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/feature-flags"
      secret_data = "{\"enable_new_ui\":true,\"enable_beta_api\":false}"
    }
    "temp-migration-key-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/temp-migration-key"
      secret_data = "migration-key-xyz789"
    }
    "contractor-token-v1" = {
      secret_id             = "projects/my-gcp-project/secrets/contractor-access-token"
      secret_data           = "Y29udHJhY3Rvci10b2tlbi12YWx1ZQ=="
      is_secret_data_base64 = true
    }
  }

  # ---------- IAM Bindings ----------
  secret_iam_bindings = {
    "db-creds-backend" = {
      secret_id = "projects/my-gcp-project/secrets/database-credentials"
      role      = "roles/secretmanager.secretAccessor"
      members = [
        "serviceAccount:app-backend@my-gcp-project.iam.gserviceaccount.com",
        "serviceAccount:data-pipeline@my-gcp-project.iam.gserviceaccount.com",
      ]
    }
    "db-creds-cicd" = {
      secret_id = "projects/my-gcp-project/secrets/database-credentials"
      role      = "roles/secretmanager.secretVersionAdder"
      members   = ["serviceAccount:cicd-runner@my-gcp-project.iam.gserviceaccount.com"]
    }
    "api-key-gateway" = {
      secret_id = "projects/my-gcp-project/secrets/api-gateway-key"
      role      = "roles/secretmanager.secretAccessor"
      members   = ["serviceAccount:api-gateway@my-gcp-project.iam.gserviceaccount.com"]
    }
    "feature-flags-all" = {
      secret_id = "projects/my-gcp-project/secrets/feature-flags"
      role      = "roles/secretmanager.secretAccessor"
      members = [
        "serviceAccount:app-backend@my-gcp-project.iam.gserviceaccount.com",
        "serviceAccount:app-frontend@my-gcp-project.iam.gserviceaccount.com",
      ]
    }
    "db-creds-admin" = {
      secret_id = "projects/my-gcp-project/secrets/database-credentials"
      role      = "roles/secretmanager.admin"
      members   = ["group:platform-team@example.com"]
      condition = {
        title       = "weekday-only"
        description = "Admin access only during weekdays"
        expression  = "request.time.getDayOfWeek('America/New_York') >= 1 && request.time.getDayOfWeek('America/New_York') <= 5"
      }
    }
  }
}

# ---------- Outputs ----------
output "secret_ids" {
  value = module.secrets.secret_ids
}

output "secret_names" {
  value = module.secrets.secret_names
}

output "secret_version_ids" {
  value = module.secrets.secret_version_ids
}
