output "application_url" {
  description = "Starter application URL after the Helm deployment completes"
  value       = "http://${module.ec2.public_ip}"
}

output "instance_id" { value = module.ec2.instance_id }
output "database_endpoint" { value = module.rds.db_instance_endpoint }
output "ecr_repositories" { value = module.ecr.repository_urls }

output "database_secret_arn" {
  description = "Secrets Manager ARN read by the k3s host; do not output its value"
  value       = aws_secretsmanager_secret.database.arn
}
