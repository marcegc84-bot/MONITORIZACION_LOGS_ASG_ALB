output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "asg_arn" {
  description = "ARN del Auto Scaling Group"
  value       = aws_autoscaling_group.this.arn
}

output "security_group_id" {
  description = "Security Group de las instancias"
  value       = aws_security_group.app.id
}

output "launch_template_id" {
  description = "ID de la launch template"
  value       = aws_launch_template.this.id
}

output "iam_role_name" {
  description = "Rol IAM de las instancias"
  value       = aws_iam_role.instance.name
}

output "instance_profile_name" {
  description = "Instance profile de las instancias"
  value       = aws_iam_instance_profile.instance.name
}
