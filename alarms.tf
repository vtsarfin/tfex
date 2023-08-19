resource "aws_sns_topic" "def_topic" {
  name = "def_topic"
}

resource "aws_sns_topic_subscription" "def_subscription" {
  for_each               = toset(var.alert_emails)
  topic_arn              = aws_sns_topic.def_topic.arn
  protocol               = "email"
  endpoint               = each.value
  endpoint_auto_confirms = true
}

resource "aws_cloudwatch_composite_alarm" "lb_alarm" {
  alarm_description = "Composite alarm that LB"
  alarm_name        = "LB_Composite_Alarm"
  alarm_actions     = [aws_sns_topic.def_topic.arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.unhealthy_host_count_alarm.alarm_name})"

  depends_on = [
    aws_cloudwatch_metric_alarm.unhealthy_host_count_alarm,
    aws_sns_topic.def_topic,
    aws_sns_topic_subscription.def_subscription
  ]
}



resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count_alarm" {
  alarm_name          = "unhealthy_host_count_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  # Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "UnHealthyHostCount"
  # The namespace for the alarm's associated metric
  namespace = "AWS/ApplicationELB"
  # After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period    = "60"
  statistic = "Maximum"
  # CPU Utilization threshold is set to 10 percent
  threshold         = "1"
  alarm_description = "This metric monitors ELB UnHealthyHostCount >= 1"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.asg.arn_suffix
  }
}
