# Monthly cost budget with email alerts — the project's cost guardrail.
# Created FIRST, before any billable resource, so spend is watched from day one.
#
# Three notifications on a single monthly budget:
#   1. actual spend    >= 50% of budget  (early heads-up)
#   2. actual spend    >= 90% of budget  (act now)
#   3. forecasted spend >= 100% of budget (projected to blow the budget)

resource "aws_budgets_budget" "monthly_cost" {
  name         = "pharma-de-monthly-cost"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
