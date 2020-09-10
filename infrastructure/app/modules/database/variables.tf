variable "project" {}

variable "database_instance_name" {}

variable "database_instance_ip" {}

variable "vpc_access_connector_name" {}

variable "location" {
  # europe-west3 not yet supported for Cloud Run: https://cloud.google.com/run/docs/locations
  default = "europe-west1"
}

variable "database_passwords" {
  type = map
}

variable "hasura_passwords" {
  type = map
}

variable "hasura_jwt_keys" {
  type = map
}
