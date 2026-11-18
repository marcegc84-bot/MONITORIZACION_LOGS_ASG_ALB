# Log group donde el CloudWatch Agent de las instancias envía sus logs.
# El rol IAM que permite escribir en él vive en el módulo asg (instance profile).
resource "aws_cloudwatch_log_group" "asg_logs" {
  name              = "/${var.name}/asg/instance"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id

  tags = var.tags
}
