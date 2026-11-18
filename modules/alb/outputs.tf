output "alb_arn" {
  description = "ARN del ALB"
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "Sufijo del ARN del ALB (dimensión LoadBalancer de CloudWatch)"
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "DNS del ALB"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID del ALB (para registros alias de Route 53)"
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN del target group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "Sufijo del ARN del target group (dimensión TargetGroup de CloudWatch)"
  value       = aws_lb_target_group.this.arn_suffix
}

output "listener_arn" {
  description = "ARN del listener principal (443 si hay certificado, 80 si no)"
  value       = local.https_enabled ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
}

output "access_logs_bucket" {
  description = "Nombre del bucket de access logs (null si están desactivados)"
  value       = one(aws_s3_bucket.logs[*].id)
}
