resource "aws_cloudwatch_dashboard" "infra_dashboard" {
  dashboard_name = "infra-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      # --- 1. ASG CPU UTILIZATION ---
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ASG CPU Utilization",
          "view" : "timeSeries",
          "region" : var.region,
          "stat" : "Average",
          "period" : 60,
          "metrics" : [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              var.asg_name
            ]
          ]
        }
      },

      # --- 2. TARGET GROUP UNHEALTHY HOSTS ---
      {
        "type" : "metric",
        "x" : 12,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Unhealthy Hosts (Target Group)",
          "view" : "timeSeries",
          "region" : var.region,
          "stat" : "Maximum",
          "period" : 60,
          "metrics" : [
            [
              "AWS/ApplicationELB",
              "UnHealthyHostCount",
              "TargetGroup",
              var.tg_arn_suffix,
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      },

      # --- 3. ALB TARGET RESPONSE TIME ---
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ALB Target Response Time",
          "view" : "timeSeries",
          "region" : var.region,
          "stat" : "Average",
          "period" : 60,
          "metrics" : [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      },

      # --- 4. ALB REQUEST COUNT ---
      {
        "type" : "metric",
        "x" : 12,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ALB Request Count",
          "view" : "timeSeries",
          "region" : var.region,
          "stat" : "Sum",
          "period" : 60,
          "metrics" : [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      },

      # --- 5. ALB 5XX ERRORS ---
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "title" : "ALB 5XX Errors",
          "view" : "timeSeries",
          "region" : var.region,
          "stat" : "Sum",
          "period" : 60,
          "metrics" : [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      }

    ]
  })
}
