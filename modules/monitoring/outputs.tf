output "sns_topic_arn" {
  description = "ARN del topic SNS de alertas"
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch"
  value       = aws_cloudwatch_dashboard.infra_dashboard.dashboard_name
}
