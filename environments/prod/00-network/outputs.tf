# Este contrato de outputs lo leen las demás capas con terraform_remote_state
# (10-asg-alb ahora, y 20-eks más adelante). No cambies los nombres sin actualizarlas.

output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "azs" {
  value = module.network.azs
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.network.nat_gateway_ids
}

# Nombre del clúster EKS: lo lee 20-eks, así el nombre de las etiquetas de subnets
# y el del clúster no pueden divergir. null si no se va a usar EKS en este entorno.
output "eks_cluster_name" {
  value = var.eks_cluster_name
}
