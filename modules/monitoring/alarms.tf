resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ---- ALB 5XX ----
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.name}-alb-5xx-errors"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching" # sin tráfico no hay métrica; evita falsas alarmas

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  tags          = var.tags
}

# ---- ALB tiempo de respuesta ----
resource "aws_cloudwatch_metric_alarm" "alb_response" {
  alarm_name          = "${var.name}-alb-high-response"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.response_time_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  tags          = var.tags
}

# ---- Targets no sanos ----
resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
  alarm_name          = "${var.name}-tg-unhealthy-hosts"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = var.tg_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  tags          = var.tags
}

# ---- Políticas de escalado ----
resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "${var.name}-cpu-scale-out"
  autoscaling_group_name = var.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = var.scaling_cooldown
}

resource "aws_autoscaling_policy" "cpu_scale_in" {
  name                   = "${var.name}-cpu-scale-in"
  autoscaling_group_name = var.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = var.scaling_cooldown
}

# ---- CPU alta: avisa y escala hacia fuera ----
resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "${var.name}-asg-cpu-high"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = var.cpu_high_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_autoscaling_policy.cpu_scale_out.arn,
  ]
  tags = var.tags
}

# ---- CPU baja: avisa y escala hacia dentro ----
resource "aws_cloudwatch_metric_alarm" "asg_cpu_low" {
  alarm_name          = "${var.name}-asg-cpu-low"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.cpu_low_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_autoscaling_policy.cpu_scale_in.arn,
  ]
  tags = var.tags
}
