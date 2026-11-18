variable "aws_region" {
  description = "Región donde se despliegan los recursos"
  type        = string
}

variable "project" {
  description = "Nombre corto del proyecto (forma parte del nombre de los recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, prod...)"
  type        = string
}

variable "owner" {
  description = "Propietario, para el tag Owner"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

variable "azs" {
  description = "Zonas de disponibilidad"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subnets públicas (mismo orden que azs)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subnets privadas (mismo orden que azs)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Crear NAT Gateway (necesario si las instancias están en subnets privadas)"
  type        = bool
}

variable "single_nat_gateway" {
  description = "true: un solo NAT (dev). false: un NAT por AZ (prod)."
  type        = bool
}

variable "enable_flow_logs" {
  description = "Activar VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Retención de los flow logs"
  type        = number
  default     = 30
}

variable "eks_cluster_name" {
  description = "Si se define, las subnets se etiquetan para que EKS y el AWS Load Balancer Controller las descubran"
  type        = string
  default     = null
}
