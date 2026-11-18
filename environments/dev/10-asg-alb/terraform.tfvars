aws_region  = "us-east-1"
project     = "monlogs"
environment = "dev"
owner       = "Marce"

network_state_key = "dev/network/terraform.tfstate"

# ALB
alb_ingress_cidrs              = ["0.0.0.0/0"]
alb_deletion_protection        = false
alb_access_logs_retention_days = 30
alb_access_logs_force_destroy  = true # en dev el bucket se puede borrar con terraform destroy

# ASG
app_in_private_subnets    = true
instance_type             = "t2.micro"
min_size                  = 1
max_size                  = 3
desired_capacity          = 2
health_check_grace_period = 600

log_retention_days = 14

# alert_email: NO se escribe aquí. export TF_VAR_alert_email="tu@correo"
