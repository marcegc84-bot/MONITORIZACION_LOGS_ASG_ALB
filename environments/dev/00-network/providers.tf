terraform {
  # Configuración parcial: bucket, key y región llegan con -backend-config (ver Makefile y backend.hcl).
  # Versiones de Terraform y providers: ver versions.tf (copia de config/versions.tf).
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
