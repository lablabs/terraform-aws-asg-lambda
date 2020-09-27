# Definition of EventBridge target to invoke a Lambda function when a lifecycle action occurs
resource "aws_cloudwatch_event_rule" "self" {
  count = var.enabled ? 1 : 0

  name          = module.label.id
  description   = "Trigger a lambda function when an instance launches in the ASGs"
  event_pattern = data.template_file.aws_cloudwatch_event_rule_pattern[0].rendered

  tags = module.label.tags
}

data "template_file" "aws_cloudwatch_event_rule_pattern" {
  count = var.enabled ? 1 : 0

  template = file("${path.module}/templates/cloudwatch-event-rule.json.tpl")
  vars = {
    asg-names     = jsonencode(var.lambda_asg_target_names)
    asg-names-len = length(var.lambda_asg_target_names)
  }
}

resource "aws_cloudwatch_event_target" "self" {
  count = var.enabled ? 1 : 0

  rule = aws_cloudwatch_event_rule.self[0].name
  arn  = aws_lambda_function.self[0].arn
}

resource "aws_cloudwatch_log_group" "self" {
  count = var.enabled ? 1 : 0

  name              = "/aws/lambda/${module.label.id}"
  retention_in_days = var.lambda_log_retention

  tags = module.label.tags
}

#join("", aws_security_group.default.*.id)
