variable "project_name" { type = string }
variable "environment" { type = string }
variable "database_secret_arn" { type = string }
variable "ecr_repository_arns" { type = map(string) }
