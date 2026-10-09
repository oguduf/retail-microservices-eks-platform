output "address" {
  description = "Private DNS address of the Orders PostgreSQL database."
  value       = aws_db_instance.orders.address
}

output "identifier" {
  description = "Identifier of the Orders RDS instance."
  value       = aws_db_instance.orders.identifier
}

output "resource_id" {
  description = "Immutable RDS resource ID used in IAM database permissions."
  value       = aws_db_instance.orders.resource_id
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed master user secret."
  value       = aws_db_instance.orders.master_user_secret[0].secret_arn
}

output "kms_key_arn" {
  description = "KMS key used for Orders database storage and credentials."
  value       = aws_kms_key.orders_database.arn
}
