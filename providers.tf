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
  default_tags {
    tags = var.tags
  }
}

