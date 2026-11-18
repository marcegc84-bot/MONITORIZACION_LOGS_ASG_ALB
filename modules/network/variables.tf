variable "name" {
  description = "Prefijo de nombre de los recursos (ej. monlogs-dev)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr debe ser un CIDR IPv4 válido."
  }
}

variable "azs" {
  description = "Zonas de disponibilidad. Se crea una subnet pública y una privada por AZ."
  type        = list(string)

  validation {
    condition = (
      length(var.azs) >= 2 &&
      length(var.azs) == length(var.public_subnet_cidrs) &&
      length(var.azs) == length(var.private_subnet_cidrs)
    )
    error_message = "Hacen falta al menos 2 AZ y el mismo número de CIDRs públicos y privados."
  }
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
  description = "Crear NAT Gateway para que las subnets privadas tengan salida a internet"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "true: un único NAT (barato, para dev). false: un NAT por AZ (alta disponibilidad, para prod)."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enviar VPC Flow Logs a CloudWatch Logs"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Retención de los flow logs en días"
  type        = number
  default     = 30
}

variable "public_subnet_tags" {
  description = "Tags extra para las subnets públicas (ej. etiquetas de EKS)"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Tags extra para las subnets privadas (ej. etiquetas de EKS)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
