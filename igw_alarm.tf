##
/* ####
resource "aws_cloudwatch_metric_alarm" "CloudWatchAlarm" {
  alarm_name = "igw_changes"
  alarm_description = "A CloudWatch Alarm that triggers when changes are made to an Internet Gateway in a VPC."
  metric_name = "GatewayEventCount"
  namespace = "CloudTrailMetrics"
  statistic = "Sum"
  period = "300"
  threshold = "1"
  evaluation_periods = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions = [ module.SnsTopic.arn ]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "MetricFilter" {
  log_group_name = ""
  pattern = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"
  name = "GatewayEventCount"

  metric_transformation {
    name = "GatewayEventCount"
    value = "1"
    namespace = "CloudTrailMetrics"
  }

}
*/
