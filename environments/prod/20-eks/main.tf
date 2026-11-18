locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Stack       = "eks"
  }

  # El nombre del clúster sale de 00-network (el mismo que usan las etiquetas de las subnets)
  cluster_name = try(data.terraform_remote_state.network.outputs.eks_cluster_name, null)

  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  alb_security_group_id = var.enable_alb_integration ? data.terraform_remote_state.asg_alb[0].outputs.alb_sg_id : null
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.network_state_key
    region = var.aws_region
  }
}

data "terraform_remote_state" "asg_alb" {
  count   = var.enable_alb_integration ? 1 : 0
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.asg_alb_state_key
    region = var.aws_region
  }
}

resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = local.cluster_name != null
      error_message = "00-network no exporta eks_cluster_name. Define eks_cluster_name en el terraform.tfvars de 00-network y vuelve a aplicarlo (solo añade etiquetas a las subnets y un output)."
    }
  }
}

module "eks" {
  source = "../../../modules/eks"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version
  subnet_ids         = local.private_subnet_ids

  endpoint_public_access = var.endpoint_public_access
  public_access_cidrs    = var.api_allowed_cidrs
  cluster_admin_arns     = var.cluster_admin_arns

  enable_secrets_encryption = var.enable_secrets_encryption
  log_retention_days        = var.log_retention_days
  addon_versions            = var.addon_versions
  node_groups               = var.node_groups

  alb_security_group_id = local.alb_security_group_id
  app_port              = var.app_port

  tags = local.common_tags

  depends_on = [terraform_data.guard]
}
