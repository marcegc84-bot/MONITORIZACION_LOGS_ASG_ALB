# ----------------------------------------------------------- Generales
variable "aws_region" {
  description = "Región donde se despliegan los recursos"
  type        = string
}

variable "project" {
  description = "Nombre corto del proyecto"
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

# ---------------------------------------------------- Estado de otras capas
variable "state_bucket" {
  description = "Bucket S3 con el estado de las demás capas (lo rellena el Makefile con TF_VAR_state_bucket)"
  type        = string
}

variable "network_state_key" {
  description = "Clave del estado de 00-network"
  type        = string
}

variable "asg_alb_state_key" {
  description = "Clave del estado de 10-asg-alb"
  type        = string
}

variable "enable_alb_integration" {
  description = "true: lee 10-asg-alb y permite que su ALB llegue a los pods (migración gradual ASG -> EKS)"
  type        = bool
  default     = true
}

variable "app_port" {
  description = "Puerto de los pods al que llega el ALB. Debe coincidir con app_port de 10-asg-alb."
  type        = number
  default     = 80
}

# ------------------------------------------------------------- Clúster
variable "kubernetes_version" {
  description = "Versión de Kubernetes. Comprueba en la documentación de EKS cuáles están en soporte estándar."
  type        = string
}

variable "endpoint_public_access" {
  description = "Endpoint público del API server"
  type        = bool
  default     = true
}

variable "api_allowed_cidrs" {
  description = "CIDRs con acceso al endpoint público. No se guarda en el repo: export TF_VAR_api_allowed_cidrs='[\"x.x.x.x/32\"]'"
  type        = list(string)
  default     = []
}

variable "cluster_admin_arns" {
  description = "ARNs IAM adicionales con rol de administrador del clúster"
  type        = list(string)
  default     = []
}

variable "enable_secrets_encryption" {
  description = "Cifrar los Secrets de Kubernetes con una clave KMS"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Retención de los logs del control plane"
  type        = number
  default     = 30
}

variable "addon_versions" {
  description = "Versiones fijadas de add-ons (vacío = por defecto de EKS)"
  type        = map(string)
  default     = {}
}

variable "node_groups" {
  description = "Managed node groups"
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    ami_type       = optional(string, "AL2023_x86_64_STANDARD")
    disk_size      = optional(number, 20)
    min_size       = number
    desired_size   = number
    max_size       = number
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
  }))
}
