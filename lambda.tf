locals {
  lambda_zip_filename  = "${var.lambda_function_zip_filename}${var.lambda_function_version}.zip"
  lambda_zip_file_path = abspath(local.lambda_zip_filename)
  lambda_url           = "${var.lambda_function_zip_base_url}${var.lambda_function_version}/${var.lambda_function_zip_filename}${var.lambda_function_version}.zip"
}

resource "null_resource" "lambda_zip" {
  count = var.enabled ? 1 : 0

  triggers = {
    url : var.lambda_function_zip_base_url
    filename : var.lambda_function_zip_filename
    version : var.lambda_function_version
  }

  provisioner "local-exec" {
    command = "curl -sSL -o ${local.lambda_zip_filename} ${local.lambda_url}"
  }
}

resource "aws_lambda_function" "self" {
  count = var.enabled ? 1 : 0

  function_name = module.label.id
  filename      = local.lambda_zip_file_path

  role        = aws_iam_role.self[0].arn
  handler     = "main.handle"
  description = "ASG lambda triggered by ASG EC2 Instance-launch Lifecycle Action"
  memory_size = 128
  runtime     = "python3.8"
  timeout     = 30

  environment {
    variables = {
      EIP                  = var.eip_attach
      ENI                  = var.eni_attach
      EBS                  = var.ebs_attach
      EIP_TAG_FILTER_NAME  = var.eip_tag_filter_name
      EIP_TAG_FILTER_VALUE = var.eip_tag_filter_value
      ENI_TAG_FILTER_NAME  = var.eni_tag_filter_name
      ENI_TAG_FILTER_VALUE = var.eni_tag_filter_value
      EBS_TAG_FILTER_NAME  = var.ebs_tag_filter_name
      EBS_TAG_FILTER_VALUE = var.ebs_tag_filter_value
      EBS_DEVICE_NAME      = var.ebs_device_name
    }
  }

  tags = module.label.tags

  depends_on = [
    null_resource.lambda_zip,
    aws_cloudwatch_log_group.self
  ]
}

resource "aws_lambda_permission" "self" {
  count = var.enabled ? 1 : 0

  statement_id  = "${module.label.id}-AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.self[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.self[0].arn
}
