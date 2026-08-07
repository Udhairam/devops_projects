# --- CloudWatch Log Group ---

resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/ec2/${local.name_prefix}"
  retention_in_days = 30
  tags              = local.common_tags
}

# --- CPU alarms wired to ASG scaling policies ---

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.cpu_scale_out_threshold
  alarm_description   = "Scale out: CPU > ${var.cpu_scale_out_threshold}% for 4 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  ok_actions          = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.cpu_scale_in_threshold
  alarm_description   = "Scale in: CPU < ${var.cpu_scale_in_threshold}% for 4 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  ok_actions          = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is receiving elevated 5xx errors from targets"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.web.arn_suffix
    TargetGroup  = aws_lb_target_group.web.arn_suffix
  }

  tags = local.common_tags
}

# --- CloudWatch Dashboard ---

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-ops"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ASG CPU Utilization"
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          region = var.aws_region
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.web.name,
            { label = "CPU %", color = "#58a6ff" }]
          ]
          annotations = {
            horizontal = [
              { value = var.cpu_scale_out_threshold, label = "Scale Out", color = "#f85149" },
              { value = var.cpu_scale_in_threshold, label = "Scale In", color = "#3fb950" }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count"
          view   = "timeSeries"
          stat   = "Sum"
          period = 60
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.web.arn_suffix,
            { label = "Requests/min", color = "#3fb950" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB 5xx Errors"
          view   = "timeSeries"
          stat   = "Sum"
          period = 60
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer",
            aws_lb.web.arn_suffix, { label = "5xx errors", color = "#f85149" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ASG Instance Count"
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          region = var.aws_region
          metrics = [
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName",
            aws_autoscaling_group.web.name, { label = "In-service", color = "#3fb950" }],
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName",
            aws_autoscaling_group.web.name, { label = "Desired", color = "#58a6ff" }]
          ]
        }
      }
    ]
  })
}
