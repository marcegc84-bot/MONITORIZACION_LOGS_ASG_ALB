aws_region  = "us-east-1"
project     = "monlogs"
environment = "prod"
owner       = "Marce"

network_state_key = "prod/network/terraform.tfstate"
asg_alb_state_key = "prod/asg-alb/terraform.tfstate"

enable_alb_integration = true
app_port               = 80

kubernetes_version = "1.36"

# En prod el API server no se expone a internet: acceso desde dentro de la VPC (VPN, bastion o SSM)
endpoint_public_access = false

# Roles IAM que administrarán el clúster además de quien lo crea
# cluster_admin_arns = ["arn:aws:iam::<cuenta>:role/<rol-admin>"]

enable_secrets_encryption = true
log_retention_days        = 90

# Fijar versiones de add-ons en prod (consulta: aws eks describe-addon-versions)
# addon_versions = { "vpc-cni" = "v1.x.x-eksbuild.x" }

node_groups = {
  general = {
    instance_types = ["t3.large"]
    min_size       = 3
    desired_size   = 3
    max_size       = 6
    labels         = { role = "general" }
  }

  monitoring = {
    instance_types = ["t3.large"]
    min_size       = 2
    desired_size   = 2
    max_size       = 3
    labels         = { role = "monitoring" }
    taints = [{
      key    = "dedicated"
      value  = "monitoring"
      effect = "NO_SCHEDULE"
    }]
  }
}
