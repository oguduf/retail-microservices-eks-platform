output "mysql_endpoint" {
  description = "Private MySQL endpoint for Product and Order services."
  value       = aws_db_instance.mysql.address
}

output "mysql_port" {
  description = "MySQL port."
  value       = aws_db_instance.mysql.port
}

output "mysql_master_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = aws_db_instance.mysql.master_user_secret[0].secret_arn
}

output "mysql_security_group_id" {
  description = "Security group protecting the MySQL instance."
  value       = aws_security_group.mysql.id
}

output "inventory_table_name" {
  description = "DynamoDB inventory table name."
  value       = aws_dynamodb_table.inventory.name
}

output "notification_table_name" {
  description = "DynamoDB notification table name."
  value       = aws_dynamodb_table.notification.name
}