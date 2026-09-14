output "db_instance_endpoint" {
  description = "The connection endpoint for the MySQL RDS instance"
  value       = aws_db_instance.mysql.endpoint
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.mysql.id
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.mysql.db_name
}