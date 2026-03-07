###############################################################################
# Advanced Example — CMEK, Rotation, Pub/Sub Notifications
###############################################################################

module "secrets" {
  source = "../../"

  project_id = "my-gcp-project"

  labels = {
    team        = "platform"
    environment = "production"
  }

  secrets = {
    # Secret with user-managed replication and CMEK
    "database-password" = {
      labels = {
        sensitivity = "high"
      }
      replication = {
        user_managed = {
          replicas = [
            {
              location = "us-central1"
              customer_managed_encryption = {
                kms_key_name = "projects/my-gcp-project/locations/us-central1/keyRings/secrets-ring/cryptoKeys/secrets-key"
              }
            },
            {
              location = "us-east1"
              customer_managed_encryption = {
                kms_key_name = "projects/my-gcp-project/locations/us-east1/keyRings/secrets-ring/cryptoKeys/secrets-key"
              }
            },
          ]
        }
      }
      rotation = {
        rotation_period    = "7776000s"
        next_rotation_time = "2025-01-01T00:00:00Z"
      }
      topics = [
        { name = "projects/my-gcp-project/topics/secret-rotation-events" }
      ]
    }

    # Secret with auto replication and CMEK
    "service-token" = {
      replication = {
        auto = {
          customer_managed_encryption = {
            kms_key_name = "projects/my-gcp-project/locations/global/keyRings/secrets-ring/cryptoKeys/secrets-key"
          }
        }
      }
      version_aliases = {
        "current" = "1"
      }
    }
  }

  secret_versions = {
    "database-password-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/database-password"
      secret_data = "super-secure-password-v1"
    }
    "service-token-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/service-token"
      secret_data = "eyJhbGciOiJIUzI1NiJ9.dG9rZW4.signature"
    }
  }

  secret_iam_bindings = {
    "db-password-accessor" = {
      secret_id = "projects/my-gcp-project/secrets/database-password"
      role      = "roles/secretmanager.secretAccessor"
      members = [
        "serviceAccount:app-backend@my-gcp-project.iam.gserviceaccount.com",
      ]
      condition = {
        title      = "prod-only"
        expression = "resource.name.startsWith(\"projects/my-gcp-project\")"
      }
    }
    "token-version-adder" = {
      secret_id = "projects/my-gcp-project/secrets/service-token"
      role      = "roles/secretmanager.secretVersionAdder"
      members   = ["serviceAccount:cicd-runner@my-gcp-project.iam.gserviceaccount.com"]
    }
  }
}

output "secret_ids" {
  value = module.secrets.secret_ids
}

output "secret_version_names" {
  value = module.secrets.secret_version_names
}
