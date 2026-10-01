variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "instance_type" { type = string }
variable "key_name" {
  type     = string
  default  = null
  nullable = true
}
variable "iam_instance_profile" { type = string }
variable "database_secret_name" { type = string }
variable "mysql_volume_size" { type = number }
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
