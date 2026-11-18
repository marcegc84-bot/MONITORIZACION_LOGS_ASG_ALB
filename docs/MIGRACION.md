# Migración desde la versión plana original

| Antes | Ahora |
|---|---|
| Todo en la raíz, estado local | Módulos + entornos, estado remoto en S3 con bloqueo |
| Subnets privadas sin AZ, sin tabla de rutas y con nombre `public-...` | AZ explícita, tabla de rutas por AZ y salida por NAT |
| Ruta pública con destino `var.sg_ingress_cidr` | Ruta `0.0.0.0/0` al Internet Gateway |
| SSH abierto a `0.0.0.0/0` | Sin SSH; acceso por SSM Session Manager |
| Instancias en subnets públicas | Subnets privadas (configurable) |
| AMI fija en tfvars | Última Amazon Linux 2023 o AMI fijada con `ami_id` |
| Disco sin cifrar, IMDSv1 | EBS gp3 cifrado, IMDSv2 obligatorio |
| SG de instancias con salida total | Salida solo por 80 y 443 |
| Nombres fijos (`ec2-cloudwatch-agent-role`, `/ecs/asg/instance`, `infra-dashboard`) | Prefijo `<proyecto>-<entorno>`: dev y prod pueden coexistir |
| Bucket de logs con sufijo aleatorio, sin cifrado ni expiración | Sufijo = id de cuenta, cifrado, solo TLS, expiración y sin acceso público |
| Email de alertas escrito en `main.tf` | Variable `TF_VAR_alert_email` |
| Provider `aws 4.46.0`, Terraform `~>1.12.0` | `aws >= 5.60, < 7.0`, Terraform `>= 1.10` |
| ASG con `$Latest` y `desired_capacity` fija | Instance refresh gradual; Terraform ignora la capacidad que cambian las políticas de escalado |
| `random`, `userdata_nginx_bkup.sh` y alarmas comentadas | Eliminados |

Se mantienen sin cambios: el script de userdata (nginx + CloudWatch Agent), las alarmas (5XX, tiempo de respuesta, targets no sanos, CPU alta/baja), las políticas de escalado y el dashboard.

