variable "name" {
  description = "Prefijo de nombre (el log group será /<name>/asg/instance)"
  type        = string
}

variable "retention_in_days" {
  description = "Retención de los logs en días"
  type        = number
  default     = 14
}

variable "kms_key_id" {
  description = "ARN de una clave KMS para cifrar el log group (null = cifrado por defecto de CloudWatch)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
