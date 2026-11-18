output "alb_dns_name" {
  description = "DNS del ALB (abre http://<valor> en el navegador)"
  value       = module.alb.alb_dns_name
}

# ---- Contrato para la capa 20-eks (TargetGroupBinding sobre este ALB) ----
output "alb_arn" {
  value = module.alb.alb_arn
}

output "alb_sg_id" {
  value = module.alb.security_group_id
}

output "listener_arn" {
  value = module.alb.listener_arn
}

output "legacy_tg_arn" {
  description = "Target group del ASG (el 'legacy' frente al target group de EKS)"
  value       = module.alb.target_group_arn
}

# ---- Otros ----
output "asg_name" {
  value = module.asg.asg_name
}

output "app_security_group_id" {
  value = module.asg.security_group_id
}

output "log_group_name" {
  value = module.cw_logs.log_group_name
}

output "alb_access_logs_bucket" {
  value = module.alb.access_logs_bucket
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}

output "dashboard_name" {
  value = module.monitoring.dashboard_name
}
