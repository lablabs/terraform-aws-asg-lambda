# Definition of EventBridge target to invoke a Lambda function when a lifecycle action occurs
resource "aws_cloudwatch_event_rule" "self" {
  name          = module.label.id
  description   = "Trigger a lambda function when an instance launches in the ASGs"
  event_pattern = data.template_file.aws_cloudwatch_event_rule_pattern.rendered

  tags = module.label.tags
}

data "template_file" "aws_cloudwatch_event_rule_pattern" {
  template = file("${path.module}/templates/cloudwatch-event-rule.json.tpl")
  vars = {
    asg-names     = jsonencode(var.lambda_asg_target_names)
    asg-names-len = length(var.lambda_asg_target_names)
  }
}

resource "aws_cloudwatch_event_target" "self" {
  rule = aws_cloudwatch_event_rule.self.name
  arn  = aws_lambda_function.self.arn
}


resource "aws_cloudwatch_log_group" "self" {
  name              = "/aws/lambda/${module.label.id}"
  retention_in_days = var.lambda_log_retention

  tags = module.label.tags
}
