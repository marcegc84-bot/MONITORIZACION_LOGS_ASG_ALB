aws_region  = "us-east-1"
project     = "monlogs"
environment = "dev"
owner       = "Marce"

# Mismos rangos que el proyecto original
vpc_cidr             = "10.10.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.50.0/24", "10.10.51.0/24"]

# NAT: ~32 USD/mes + tráfico. Para ahorrar en el laboratorio:
#   enable_nat_gateway = false  y  app_in_private_subnets = false en 10-asg-alb
enable_nat_gateway = true
single_nat_gateway = true

enable_flow_logs = false

# Etiquetas de subnets para el futuro clúster EKS (lo usa 20-eks)
eks_cluster_name = "monlogs-dev-eks"
