output "log_group_name" {
  description = "Nombre del log group"
  value       = aws_cloudwatch_log_group.asg_logs.name
}

output "log_group_arn" {
  description = "ARN del log group"
  value       = aws_cloudwatch_log_group.asg_logs.arn
}
