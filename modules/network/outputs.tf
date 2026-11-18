output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.this.cidr_block
}

output "azs" {
  description = "AZ utilizadas"
  value       = var.azs
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas, en el mismo orden que azs"
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas, en el mismo orden que azs"
  value       = [for az in var.azs : aws_subnet.private[az].id]
}

output "public_route_table_id" {
  description = "ID de la tabla de rutas pública"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs de las tablas de rutas privadas, en el mismo orden que azs"
  value       = [for az in var.azs : aws_route_table.private[az].id]
}

output "nat_gateway_ids" {
  description = "IDs de los NAT Gateways (vacío si no hay NAT)"
  value       = [for az in local.nat_azs : aws_nat_gateway.this[az].id]
}
