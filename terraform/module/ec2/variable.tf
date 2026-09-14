variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID to deploy the EC2 instance into"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "user1"
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP (Set to true if in public subnet)"
  type        = bool
  default     = false
}