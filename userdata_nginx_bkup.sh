#!/bin/bash
# Actualizar paquetes
dnf update -y

# Instalar Nginx
dnf install -y nginx

# Habilitar y arrancar Nginx
systemctl enable nginx
systemctl start nginx

# Crear directorio por si aún no existe
mkdir -p /usr/share/nginx/html

# Crear página de inicio
echo "Hola desde Nginx" > /usr/share/nginx/html/index.html