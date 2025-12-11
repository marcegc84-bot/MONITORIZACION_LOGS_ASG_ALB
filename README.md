# MONITORIZACION_LOGS_ASG_ALB

La infraestructura escrita en los ficheros de terraform está compuesta por los siguientes recursos:
-	ALB (application load balancer)
-	ASG (auto scaling group)
-	Sistema de Monitorización con alertado de toda la infraestructura, que, por un lado, registra la actividad del ALB (los logs) y los almacena en bucket S3. Y por otro lado activa el ASG para aumentar o disminuir las instancias y también enviar alertas sobre el estado de estas instancias, a los meil´s suscritos al topic sns (al desplegar la infraestructura llega un correo par aceptar la suscripción).
Para simplificar el entendimiento de todo el código, se han creado dos módulos para crear el flujo logs y el sistema de monitorización.

