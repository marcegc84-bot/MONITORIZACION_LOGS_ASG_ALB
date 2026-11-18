variable "name" {
  description = "Prefijo de nombre (ej. monlogs-dev)"
  type        = string
}

variable "region" {
  description = "Región de AWS (para los widgets del dashboard)"
  type        = string
}

variable "alb_arn_suffix" {
  description = "Sufijo del ARN del ALB"
  type        = string
}

variable "tg_arn_suffix" {
  description = "Sufijo del ARN del target group"
  type        = string
}

variable "asg_name" {
  description = "Nombre del Auto Scaling Group"
  type        = string
}

variable "alert_email" {
  description = "Email que recibe las alertas (hay que confirmar la suscripción desde el correo)"
  type        = string
}

variable "alb_5xx_threshold" {
  description = "Errores 5XX del ALB por minuto que disparan la alarma"
  type        = number
  default     = 1
}

variable "response_time_threshold" {
  description = "Tiempo de respuesta medio (segundos) que dispara la alarma"
  type        = number
  default     = 1
}

variable "cpu_high_threshold" {
  description = "CPU media (%) a partir de la cual se escala hacia fuera"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU media (%) por debajo de la cual se escala hacia dentro"
  type        = number
  default     = 30
}

variable "scaling_cooldown" {
  description = "Segundos de espera entre acciones de escalado"
  type        = number
  default     = 180
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
