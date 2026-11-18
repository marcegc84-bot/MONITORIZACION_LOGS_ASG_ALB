variable "name" {
  description = "Prefijo de nombre (el ALB será <name>-alb, máx. 32 caracteres en total)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets públicas del ALB (mínimo 2, en AZ distintas)"
  type        = list(string)
}

variable "ingress_cidrs" {
  description = "CIDRs que pueden llegar al ALB por 80/443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_cidrs" {
  description = "CIDRs hacia los que el ALB puede enviar tráfico a los targets (normalmente el CIDR de la VPC)"
  type        = list(string)
}

variable "target_port" {
  description = "Puerto de los targets"
  type        = number
  default     = 80
}

variable "certificate_arn" {
  description = "ARN de un certificado ACM. Si se define: HTTPS en 443 y redirección 80 -> 443."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "Política TLS del listener HTTPS"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "health_check" {
  description = "Health check del target group"
  type = object({
    path                = optional(string, "/")
    matcher             = optional(string, "200")
    interval            = optional(number, 30)
    timeout             = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
  })
  default = {}
}

variable "deregistration_delay" {
  description = "Segundos que se espera antes de sacar un target del balanceador"
  type        = number
  default     = 30
}

variable "idle_timeout" {
  description = "Idle timeout del ALB en segundos"
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Protege el ALB contra borrado accidental"
  type        = bool
  default     = false
}

variable "enable_access_logs" {
  description = "Guardar access logs del ALB en un bucket S3 propio"
  type        = bool
  default     = true
}

variable "access_logs_retention_days" {
  description = "Días que se conservan los access logs"
  type        = number
  default     = 90
}

variable "access_logs_force_destroy" {
  description = "Permite destruir el bucket aunque tenga objetos (true solo en dev)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
