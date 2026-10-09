output "budget_name" {
  description = "Budget name, or null when no alert email is configured."
  value       = try(aws_budgets_budget.monthly_cost[0].name, null)
}
