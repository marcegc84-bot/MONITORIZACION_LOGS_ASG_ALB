output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

# ---- Contrato para la futura capa 30-addons (Helm: LB controller, Prometheus, Argo CD) ----
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_host" {
  value = module.eks.oidc_provider_host
}

output "node_role_arn" {
  value = module.eks.node_role_arn
}

output "kubeconfig_command" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
