output "lambda_function_attributes" {
  description = "ASG lambda attributes"
  value       = aws_lambda_function.self
}

output "labmda_iam_role_attributes" {
  description = "Lambda iam role attributes"
  value       = aws_iam_role_policy.self
}

output "cloudwatch_event_rule_attributes" {
  description = "CloudWatch Event Rule resource attributes"
  value       = aws_cloudwatch_event_rule.self
}
