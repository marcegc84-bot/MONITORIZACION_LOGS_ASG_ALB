locals {
  name = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Stack       = "asg-alb"
  }

  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr           = data.terraform_remote_state.network.outputs.vpc_cidr
  public_subnet_ids  = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  app_subnet_ids = var.app_in_private_subnets ? local.private_subnet_ids : local.public_subnet_ids
}

# La red vive en otra capa con su propio estado
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.network_state_key
    region = var.aws_region
  }
}

module "cw_logs" {
  source = "../../../modules/cw_logs"

  name              = local.name
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

module "alb" {
  source = "../../../modules/alb"

  name       = local.name
  vpc_id     = local.vpc_id
  subnet_ids = local.public_subnet_ids

  ingress_cidrs   = var.alb_ingress_cidrs
  egress_cidrs    = [local.vpc_cidr]
  target_port     = var.app_port
  certificate_arn = var.certificate_arn

  enable_deletion_protection = var.alb_deletion_protection
  access_logs_retention_days = var.alb_access_logs_retention_days
  access_logs_force_destroy  = var.alb_access_logs_force_destroy

  tags = local.common_tags
}

module "asg" {
  source = "../../../modules/asg"

  name                        = local.name
  vpc_id                      = local.vpc_id
  subnet_ids                  = local.app_subnet_ids
  associate_public_ip_address = !var.app_in_private_subnets

  alb_security_group_id = module.alb.security_group_id
  target_group_arns     = [module.alb.target_group_arn]
  app_port              = var.app_port

  instance_type             = var.instance_type
  ami_id                    = var.ami_id
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = var.health_check_grace_period

  log_group_name = module.cw_logs.log_group_name

  tags = local.common_tags
}

module "monitoring" {
  source = "../../../modules/monitoring"

  name           = local.name
  region         = var.aws_region
  alb_arn_suffix = module.alb.alb_arn_suffix
  tg_arn_suffix  = module.alb.target_group_arn_suffix
  asg_name       = module.asg.asg_name
  alert_email    = var.alert_email

  tags = local.common_tags
}
