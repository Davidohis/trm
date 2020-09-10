locals {
  cloudsql_instance_name = "${var.project}:${var.region}:${var.database_instance_name}"
}

resource "google_sql_database" "main" {
  provider = google-beta

  name = "trm-${terraform.workspace}"

  instance = var.database_instance_name
  project  = var.project
}

resource "google_sql_user" "main" {
  provider = google-beta

  name     = "trm-${terraform.workspace}"
  password = var.database_passwords[terraform.workspace]

  instance = var.database_instance_name
  project  = var.project
}

resource "google_cloud_run_service" "hasura" {
  provider = google-beta
  depends_on = [
    google_sql_database.main,
    google_sql_user.main,
  ]
  name = "trm-${terraform.workspace}-hasura"

  template {
    spec {
      containers {
        image = "europe-west3-docker.pkg.dev/techlabs-trm-test/trm/hasura:${terraform.workspace}"
        env {
          name  = "HASURA_GRAPHQL_DATABASE_URL"
          value = "postgres://trm-${terraform.workspace}:${var.database_passwords[terraform.workspace]}@/trm-${terraform.workspace}?host=/cloudsql/${local.cloudsql_instance_name}&sslmode=require"
        }
        env {
          name  = "HASURA_GRAPHQL_ENABLE_CONSOLE"
          value = "true"
        }
        env {
          name  = "HASURA_GRAPHQL_SERVER_PORT"
          value = "8080"
        }
        env {
          name  = "HASURA_GRAPHQL_ADMIN_SECRET"
          value = var.hasura_passwords[terraform.workspace]
        }
        # env {
        #   name  = "HASURA_GRAPHQL_UNAUTHORIZED_ROLE"
        #   value = "anonymous"
        # }
        env {
          name  = "HASURA_GRAPHQL_JWT_SECRET"
          value = "{\"type\":\"HS256\",\"key\":\"${var.hasura_jwt_keys[terraform.workspace]}\"}"
        }
        # TODO: check and remove workaround for https://github.com/hasura/graphql-engine/issues/4651
        env {
          name  = "HASURA_GRAPHQL_CLI_ENVIRONMENT"
          value = "default"
        }
        resources {
          limits = {
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "1"
        "run.googleapis.com/cloudsql-instances" = local.cloudsql_instance_name
        "run.googleapis.com/client-name"          = "terraform"
      }
    }
  }

  autogenerate_revision_name = true
  # europe-west3 not yet supported: https://cloud.google.com/run/docs/locations
  location = var.location
  project  = var.project
}

data "google_iam_policy" "noauth" {
  provider = google-beta

  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "hasura" {
  provider = google-beta

  location = google_cloud_run_service.hasura.location
  project  = google_cloud_run_service.hasura.project
  service  = google_cloud_run_service.hasura.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
