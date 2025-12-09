variable "aws_region" {
  description = "region donde se despligan los recursos"
  type = string
}  

variable "virginia_cidr" {
  description = "CIDR virginia"
  type        = string
  sensitive   = false
}

variable "publicsubnets" {
  description = "Lista de subnets publicas"
  type        = list(string)

}
variable "privatesubnets" {
  description = "Lista de subnets privadas"
  type        = list(string)
}

variable "tags" {
  description = "Tags del proyecto"
  type        = map(string)
}

variable "sg_ingress_cidr" {
  description = "CIDR for ingress traffic"
  type        = string

}

variable "ec2_specs" {
  description = "Parametros de la instancia"
  type        = map(string)
}

variable "azs" {
  description = "Lista de zonas de disponibilidad"
  type = list(string)

}

variable "ingress_ports_list" {
  description = "Lista de puertos de ingress"
  type        = list(number)

}
