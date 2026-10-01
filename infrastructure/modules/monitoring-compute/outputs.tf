output "event_processor_function_name" {
  description = "Name of the SQS event processor Lambda function."
  value       = aws_lambda_function.event_processor.function_name
}

output "event_query_api_function_name" {
  description = "Name of the query API Lambda function."
  value       = aws_lambda_function.event_query_api.function_name
}

output "events_api_endpoint" {
  description = "Base HTTPS endpoint for the monitoring query API."
  value       = aws_apigatewayv2_api.events.api_endpoint
}
