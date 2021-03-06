resource "aws_iam_role_policy" "self" {
  count = var.enabled ? 1 : 0

  name = module.label.id
  role = aws_iam_role.self[0].id

  # FIXME: POLP (principle of least privilege)
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "ec2:*",
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "self" {
  count = var.enabled ? 1 : 0

  name = module.label.id

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = module.label.tags
}
