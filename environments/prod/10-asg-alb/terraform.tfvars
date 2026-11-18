aws_region  = "us-east-1"
project     = "monlogs"
environment = "prod"
owner       = "Marce"

network_state_key = "prod/network/terraform.tfstate"

# ALB
# Para HTTPS: certificate_arn = "arn:aws:acm:us-east-1:<cuenta>:certificate/<id>"
# (con certificado, el 80 redirige al 443)
alb_ingress_cidrs              = ["0.0.0.0/0"]
certificate_arn                = null
alb_deletion_protection        = true
alb_access_logs_retention_days = 90
alb_access_logs_force_destroy  = false

# ASG
app_in_private_subnets    = true
instance_type             = "t3.small"
min_size                  = 2
max_size                  = 6
desired_capacity          = 3
health_check_grace_period = 300

# Recomendado en prod: fijar la AMI en lugar de usar siempre la última
# ami_id = "ami-xxxxxxxxxxxxxxxxx"

log_retention_days = 90

# alert_email: NO se escribe aquí. export TF_VAR_alert_email="tu@correo"
