output "lambda_function_attributes" {
  description = "ASG lambda attributes"
  value       = length(aws_lambda_function.self) > 0 ? aws_lambda_function.self[0] : null
}

output "labmda_iam_role_attributes" {
  description = "Lambda iam role attributes"
  value       = length(aws_iam_role_policy.self) > 0 ? aws_iam_role_policy.self[0] : null
}

output "cloudwatch_event_rule_attributes" {
  description = "CloudWatch Event Rule resource attributes"
  value       = length(aws_cloudwatch_event_rule.self) > 0 ? aws_cloudwatch_event_rule.self[0] : null
}
