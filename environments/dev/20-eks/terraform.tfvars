aws_region  = "us-east-1"
project     = "monlogs"
environment = "dev"
owner       = "Marce"

network_state_key = "dev/network/terraform.tfstate"
asg_alb_state_key = "dev/asg-alb/terraform.tfstate"

# Permite que el ALB del stack 10-asg-alb llegue a los pods (canary ASG -> EKS)
enable_alb_integration = true
app_port               = 80

# Versiones de Kubernetes en soporte estándar de EKS (oct 2026): 1.34 (hasta dic 2026), 1.35, 1.36, 1.37
kubernetes_version = "1.36"

# Acceso al API: SOLO desde tu IP. No se escribe aquí:
#   export TF_VAR_api_allowed_cidrs="[\"$(curl -s https://checkip.amazonaws.com)/32\"]"
endpoint_public_access = true

enable_secrets_encryption = false
log_retention_days        = 14

node_groups = {
  general = {
    instance_types = ["t3.medium"]
    min_size       = 2
    desired_size   = 2
    max_size       = 4
    labels         = { role = "general" }
  }

  # Nodos para Prometheus/Grafana: el taint impide que se programen otros pods.
  # Pon desired_size = 0 si todavía no has instalado el monitoring, para ahorrar coste.
  monitoring = {
    instance_types = ["t3.large"]
    min_size       = 0
    desired_size   = 1
    max_size       = 2
    labels         = { role = "monitoring" }
    taints = [{
      key    = "dedicated"
      value  = "monitoring"
      effect = "NO_SCHEDULE"
    }]
  }
}
