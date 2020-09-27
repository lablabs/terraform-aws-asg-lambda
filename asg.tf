# The lifecycle hook puts the instance into a wait state
# https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html
# https://docs.aws.amazon.com/autoscaling/ec2/userguide/cloud-watch-events.html#launch-lifecycle-action
resource "aws_autoscaling_lifecycle_hook" "self" {
  count                  = var.enabled ? length(var.lambda_asg_target_names) : 0
  name                   = "${module.label.id}-${var.lambda_asg_target_names[count.index]}"
  autoscaling_group_name = var.lambda_asg_target_names[count.index]
  default_result         = "ABANDON"
  heartbeat_timeout      = 60
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}
