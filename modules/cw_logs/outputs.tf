output "log_group_name" {
  value = aws_cloudwatch_log_group.asg_logs.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_cw_agent_profile.name
}

# output "role_name" {
#   value = aws_iam_role.ec2_cw_agent.name
# }
