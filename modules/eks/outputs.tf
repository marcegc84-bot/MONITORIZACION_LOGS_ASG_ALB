output "cluster_name" {
  description = "Nombre del clúster"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN del clúster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Endpoint del API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA del clúster en base64 (para configurar los providers helm y kubernetes)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "SG primario del clúster (lo usan los nodos gestionados)"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN del OIDC provider (para crear roles IRSA)"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_host" {
  description = "Host del OIDC provider sin https:// (para las condiciones de las trust policies IRSA)"
  value       = local.oidc_host
}

output "node_role_arn" {
  description = "ARN del rol de los nodos"
  value       = aws_iam_role.node.arn
}

output "kms_key_arn" {
  description = "ARN de la clave KMS de los Secrets (null si el cifrado está desactivado)"
  value       = one(aws_kms_key.secrets[*].arn)
}
