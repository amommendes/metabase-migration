variable "aws_region" {
    default = "us-east-1"
}

variable "aws_profile" {
    default = "default"
}
variable "metabase_pass" {}


variable "metabase_ingress" {
  type = map(object({description = string}))
  default = {
    3306 = { description = "Inbound to MySQL" }
    5432 = { description = "Inbound to PSQL" }
  }
}



locals {
  table_mapping = file("${path.module}/resources/table_mappings.json")
  task_settings = file("${path.module}/resources/task_settings.json")
}

