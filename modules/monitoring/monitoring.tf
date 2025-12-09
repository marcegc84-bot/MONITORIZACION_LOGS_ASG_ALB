resource "aws_sns_topic" "alerts" {
  name = "monitoring-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ---- ALB 5XX ERRORS ----
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "alb-5xx-errors"
  metric_name         = "HTTPCode_ELB_5XX_Count" #Este valor pertenece al namespace inidcado en la siguiente linea
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data = "notBreaching" #Si las métricas desaparecen (p. ej. durante despliegues), CloudWatch puede disparar alarmas falsas.

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
  actions_enabled = true
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ---- ALB RESPONSE TIME ----
resource "aws_cloudwatch_metric_alarm" "alb_response" {
  alarm_name          = "alb-high-response"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  actions_enabled = true
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ---- TG UNHEALTHY HOSTS ----
resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
  alarm_name          = "tg-unhealthy-hosts"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data = "notBreaching"

  dimensions = {
    TargetGroup  = var.tg_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  actions_enabled = true
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# --- SCALE OUT POLICY ---
resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "cpu-scale-out"
  #autoscaling_group_name = aws_autoscaling_group.asg_alb.name
  autoscaling_group_name = var.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1     # añade 1 instancia
  cooldown               = 180   # (opcional) tiempo para que el scaling se estabilice
}
# --- SCALE IN POLICY ---
resource "aws_autoscaling_policy" "cpu_scale_in" {
  name                   = "cpu-scale-in"
  #autoscaling_group_name = aws_autoscaling_group.asg_alb.name
  autoscaling_group_name = var.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1   # elimina 1 instancia
  cooldown               = 180
}

# # ---- ASG CPU HIGH ----
# resource "aws_cloudwatch_metric_alarm" "asg_cpu" {
#   alarm_name          = "asg-cpu-high"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   statistic           = "Average"
#   period              = 60
#   evaluation_periods  = 2
#   threshold           = 70
#   comparison_operator = "GreaterThanThreshold"

#   dimensions = {
#     AutoScalingGroupName = var.asg_name
#   }

#   actions_enabled = true
#   alarm_actions = [
#     aws_sns_topic.alerts.arn,
#     aws_autoscaling_policy.cpu_scale_out.arn
#   ]
# }

resource "aws_cloudwatch_metric_alarm" "asg_cpu" {
  alarm_name          = "asg-cpu-high"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_autoscaling_policy.cpu_scale_out.arn
  ]
}



# ---- ASG CPU HIGH ----
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "asg-cpu-low"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 30               # CPU < 30%
  comparison_operator = "LessThanThreshold"
  treat_missing_data = "notBreaching"

  dimensions = {
    #AutoScalingGroupName = aws_autoscaling_group.asg_alb.name
    AutoScalingGroupName = var.asg_name
  }

   actions_enabled = true
   alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_autoscaling_policy.cpu_scale_in.arn
  ]
} 

# # ---- ASG SYSTEM CHECK ----
# resource "aws_cloudwatch_metric_alarm" "asg_system_check" {
#   alarm_name          = "asg-system-check-failed"
#   metric_name         = "StatusCheckFailed_System"
#   namespace           = "AWS/EC2"
#   statistic           = "Maximum"
#   period              = 60
#   evaluation_periods  = 1
#   threshold           = 1
#   comparison_operator = "GreaterThanThreshold"
#   treat_missing_data = "notBreaching" #Si las métricas desaparecen (p. ej. durante despliegues), CloudWatch puede disparar alarmas falsas.
 

#   dimensions = {
#     AutoScalingGroupName = var.asg_name
#   }
  
#   actions_enabled = true
#   alarm_actions = [aws_sns_topic.alerts.arn]
# }
