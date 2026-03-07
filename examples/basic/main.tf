###############################################################################
# Basic Example — Secret with Automatic Replication
###############################################################################

module "secrets" {
  source = "../../"

  project_id = "my-gcp-project"

  secrets = {
    "api-key" = {
      replication = {
        auto = {}
      }
    }
  }

  secret_versions = {
    "api-key-v1" = {
      secret_id   = "projects/my-gcp-project/secrets/api-key"
      secret_data = "my-secret-api-key-value"
    }
  }

  secret_iam_bindings = {
    "api-key-accessor" = {
      secret_id = "projects/my-gcp-project/secrets/api-key"
      role      = "roles/secretmanager.secretAccessor"
      members   = ["serviceAccount:app-sa@my-gcp-project.iam.gserviceaccount.com"]
    }
  }
}

output "secret_ids" {
  value = module.secrets.secret_ids
}
