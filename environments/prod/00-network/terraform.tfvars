aws_region  = "us-east-1"
project     = "monlogs"
environment = "prod"
owner       = "Marce"

# 3 AZ; subnets privadas más grandes (/22) por si se añaden pods de EKS más adelante
vpc_cidr             = "10.20.0.0/16"
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
private_subnet_cidrs = ["10.20.16.0/22", "10.20.20.0/22", "10.20.24.0/22"]

# Un NAT por AZ: si cae una AZ, las demás siguen teniendo salida a internet
enable_nat_gateway = true
single_nat_gateway = false

enable_flow_logs         = true
flow_logs_retention_days = 30

eks_cluster_name = "monlogs-prod-eks"
