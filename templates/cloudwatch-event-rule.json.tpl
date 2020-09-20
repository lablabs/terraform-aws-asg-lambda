{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance-launch Lifecycle Action"
  ]
  %{ if asg-names-len > 0 }
  ,
  "detail": {
    "AutoScalingGroupName": ${asg-names}
  }
  %{ endif }
}
