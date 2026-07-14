# Input variables. Values with no default are supplied at apply time (or via a
# gitignored *.tfvars file) so nothing account-specific is committed.

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address that receives AWS budget alerts."
  type        = string
}

variable "monthly_budget_usd" {
  description = "Monthly cost budget threshold in USD."
  type        = number
  default     = 5
}
