output "dashboard_name" {
  description = "CloudWatch dashboard name for the retail platform."
  value       = aws_cloudwatch_dashboard.retail_platform.dashboard_name
}
