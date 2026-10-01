output "primary_endpoint_address" {
  description = "Private Valkey primary endpoint."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "port" {
  description = "Valkey port."
  value       = aws_elasticache_replication_group.main.port
}

output "security_group_id" {
  description = "Security group protecting the Valkey cache."
  value       = aws_security_group.cache.id
}