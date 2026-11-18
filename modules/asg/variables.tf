variable "name" {
  description = "Prefijo de nombre (ej. monlogs-dev)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets donde se lanzan las instancias"
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Asignar IP pública a las instancias (solo si están en subnets públicas)"
  type        = bool
  default     = false
}

variable "alb_security_group_id" {
  description = "Security Group del ALB: es el único origen permitido hacia las instancias"
  type        = string
}

variable "target_group_arns" {
  description = "Target groups donde se registran las instancias"
  type        = list(string)
  default     = []
}

variable "app_port" {
  description = "Puerto de la aplicación"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI fija. Si es null se usa la última Amazon Linux 2023. En prod conviene fijarla."
  type        = string
  default     = null
}

variable "ami_architecture" {
  description = "Arquitectura de la AMI cuando ami_id es null (x86_64 o arm64)"
  type        = string
  default     = "x86_64"
}

variable "min_size" {
  description = "Mínimo de instancias"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Máximo de instancias"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Instancias deseadas al crear el ASG (después lo gestionan las políticas de escalado)"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
    error_message = "desired_capacity debe estar entre min_size y max_size."
  }
}

variable "health_check_type" {
  description = "EC2 o ELB"
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "Segundos de gracia antes de evaluar la salud de una instancia nueva"
  type        = number
  default     = 600
}

variable "root_volume_size" {
  description = "Tamaño del disco raíz en GiB"
  type        = number
  default     = 8
}

variable "detailed_monitoring" {
  description = "Métricas de EC2 cada minuto (con coste)"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "Log group de CloudWatch al que el agente enviará los logs"
  type        = string
}

variable "enable_instance_refresh" {
  description = "Renovar las instancias de forma gradual cuando cambia la launch template"
  type        = bool
  default     = true
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Porcentaje mínimo de instancias sanas durante el refresh"
  type        = number
  default     = 50
}

variable "tags" {
  description = "Tags comunes (se aplican también a instancias y volúmenes)"
  type        = map(string)
  default     = {}
}
