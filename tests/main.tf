module "test" {
  source = "../"

  project_id = "test-project-id"

  labels = {
    environment = "test"
    managed_by  = "terraform"
  }

  secrets = {
    "database-password" = {
      labels = {
        component = "database"
      }
      replication = {
        auto = {}
      }
    }
    "api-key" = {
      labels = {
        component = "api"
      }
      replication = {
        user_managed = {
          replicas = [
            { location = "us-central1" },
            { location = "us-east1" },
          ]
        }
      }
    }
  }

  secret_versions = {
    "database-password-v1" = {
      secret_id   = "database-password"
      secret_data = "test-password-placeholder"
      enabled     = true
    }
  }

  secret_iam_bindings = {
    "app-db-access" = {
      secret_id = "database-password"
      role      = "roles/secretmanager.secretAccessor"
      members   = ["serviceAccount:app-service@test-project-id.iam.gserviceaccount.com"]
    }
  }
}
