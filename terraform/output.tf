output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID of the provisioned EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the provisioned EC2 instance"
  value       = module.ec2.instance_public_ip
}
# RDS
output "db_instance_endpoint" {
  description = "The connection endpoint for the MySQL RDS database"
  value       = module.rds.db_instance_endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = module.rds.db_name
}
# alb_asg
output "alb_dns_name" {
  value = module.alb_asg.alb_dns_name
}