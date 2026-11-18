variable "name" {
  description = "Nombre del clúster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes (ej. 1.36). Elige una en soporte estándar de EKS."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas para el control plane y los nodos (mínimo 2 AZ)"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Endpoint público del API server. false = solo accesible desde dentro de la VPC (VPN, bastion)."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs que pueden usar el endpoint público (tu IP /32). Obligatorio si endpoint_public_access = true."
  type        = list(string)
  default     = []

  validation {
    condition     = !var.endpoint_public_access || length(var.public_access_cidrs) > 0
    error_message = "Con endpoint público hay que indicar al menos un CIDR en public_access_cidrs (no uses 0.0.0.0/0)."
  }
}

variable "cluster_admin_arns" {
  description = "ARNs de roles/usuarios IAM adicionales con permisos de administrador del clúster (access entries). Quien crea el clúster ya es administrador."
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "Logs del control plane que se envían a CloudWatch"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "log_retention_days" {
  description = "Retención de los logs del control plane"
  type        = number
  default     = 30
}

variable "enable_secrets_encryption" {
  description = "Cifrar los Secrets de Kubernetes en etcd con una clave KMS propia"
  type        = bool
  default     = false
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

variable "addon_versions" {
  description = "Versión fijada por add-on (vpc-cni, kube-proxy, coredns, aws-ebs-csi-driver). Los que no aparezcan usan la versión por defecto de EKS."
  type        = map(string)
  default     = {}
}

variable "alb_security_group_id" {
  description = "SG de un ALB externo (el del stack 10-asg-alb) al que se permite llegar a los nodos/pods. null = no se crea la regla."
  type        = string
  default     = null
}

variable "app_port" {
  description = "Puerto de los pods al que puede llegar el ALB"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
