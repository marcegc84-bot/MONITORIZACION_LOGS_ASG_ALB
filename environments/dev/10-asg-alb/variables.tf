# ----------------------------------------------------------- Generales
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

# ------------------------------------------------------- Estado de red
variable "state_bucket" {
  description = "Bucket S3 con el estado de las demás capas (lo rellena el Makefile con TF_VAR_state_bucket)"
  type        = string
}

variable "network_state_key" {
  description = "Clave del estado de la capa 00-network dentro del bucket"
  type        = string
}

# ---------------------------------------------------------------- ALB
variable "alb_ingress_cidrs" {
  description = "CIDRs que pueden acceder al ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "certificate_arn" {
  description = "Certificado ACM para HTTPS (null = solo HTTP)"
  type        = string
  default     = null
}

variable "alb_deletion_protection" {
  description = "Protección contra borrado del ALB"
  type        = bool
  default     = false
}

variable "alb_access_logs_retention_days" {
  description = "Días de retención de los access logs del ALB"
  type        = number
  default     = 90
}

variable "alb_access_logs_force_destroy" {
  description = "Permite borrar el bucket de access logs con objetos dentro (solo dev)"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------- ASG
variable "app_in_private_subnets" {
  description = "true: instancias en subnets privadas (requiere NAT). false: en subnets públicas con IP pública (ahorra el coste del NAT en el laboratorio)."
  type        = bool
  default     = true
}

variable "app_port" {
  description = "Puerto de la aplicación"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
}

variable "ami_id" {
  description = "AMI fija (null = última Amazon Linux 2023)"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Mínimo de instancias"
  type        = number
}

variable "max_size" {
  description = "Máximo de instancias"
  type        = number
}

variable "desired_capacity" {
  description = "Instancias deseadas al crear el ASG"
  type        = number
}

variable "health_check_grace_period" {
  description = "Segundos de gracia antes de evaluar la salud de una instancia nueva"
  type        = number
  default     = 600
}

# ------------------------------------------------------ Logs y alertas
variable "log_retention_days" {
  description = "Retención de los logs de las instancias en CloudWatch"
  type        = number
  default     = 14
}

variable "alert_email" {
  description = "Email de las alertas. No se guarda en el repo: export TF_VAR_alert_email=tu@correo"
  type        = string
}
