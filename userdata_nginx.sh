#!/bin/bash
set -xe

########################################
# Actualizar paquetes
########################################
dnf update -y

########################################
# Instalar Nginx
########################################
dnf install -y nginx

# Habilitar y arrancar Nginx
systemctl enable nginx
systemctl start nginx

# Aseguramos que existe el directorio de logs de nginx
mkdir -p /var/log/nginx

# Reiniciar para asegurarnos de que los logs existen antes del CloudWatch Agent
systemctl restart nginx

# Crear directorio de html por si aún no existe
mkdir -p /usr/share/nginx/html

# Crear página de inicio
echo "Hola desde Nginx" > /usr/share/nginx/html/index.html

########################################
# Instalar CloudWatch Agent
########################################
dnf install -y amazon-cloudwatch-agent

# Crear directorios necesarios (muy importante en AL2023)
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

########################################
# Configuración de CloudWatch Agent
########################################
cat <<EOF >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${log_group}",
            "log_stream_name": "{instance_id}-system",
            "timestamp_format": "%b %d %H:%M:%S"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "${log_group}",
            "log_stream_name": "{instance_id}-nginx-access",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "${log_group}",
            "log_stream_name": "{instance_id}-nginx-error",
            "timestamp_format": "%Y/%m/%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF

# Permisos
chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

########################################
# Iniciar CloudWatch Agent
########################################
systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent
