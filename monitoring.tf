resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "sre-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggers when ASG average CPU exceeds 70% for 2 minutes"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}