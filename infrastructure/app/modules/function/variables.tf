variable "project" {}

variable "source_path" {}

variable "name" {}

variable "storage_bucket_name" {}

variable "environment_variables" {
  type = map
}

variable "timeout" {
  default = 30
}

variable "schedule" {
  default = null
}
