terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">=4.36.0, <4.47.0, !=4.43.0"
      version = "4.46.0"
    }
  }
  required_version = "~>1.12.0"
}

provider "aws" {
  # Configuration options
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = var.tags
  }
}

