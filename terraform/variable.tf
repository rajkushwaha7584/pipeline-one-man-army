variable "aws_region" {
  description = "AWS region for the starter platform"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short project identifier used in AWS resource names"
  type        = string
  default     = "three-tier-starter"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Two public subnet CIDRs, one per availability zone"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets" {
  description = "Two private subnet CIDRs for RDS, one per availability zone"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the public subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "instance_type" {
  description = "k3s host size; t3.medium is the practical minimum for this starter stack"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name; SSM is the preferred administration path"
  type        = string
  default     = null
  nullable    = true
}

variable "mysql_volume_size" {
  description = "Size in GiB of the dedicated gp3 EBS volume used by the MySQL PVC"
  type        = number
  default     = 30
}
