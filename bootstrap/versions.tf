# ORIGEN ÚNICO de las versiones de Terraform y de los providers.
#
# Este fichero se copia idéntico a cada stack (environments/*/* y bootstrap) con
# `make sync-versions`. No lo edites dentro de un stack: cambia config/versions.tf
# y ejecuta `make sync-versions`. El CI (`make check-versions`) falla si alguna copia difiere.
#
# Los módulos de modules/ no declaran versiones a propósito: las hereda el stack que los llama.
#
# Terraform solo admite un bloque required_providers por stack, por eso `tls` se declara aquí
# aunque solo lo use 20-eks (OIDC de EKS): así hay una única copia que mantener.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60, < 7.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
