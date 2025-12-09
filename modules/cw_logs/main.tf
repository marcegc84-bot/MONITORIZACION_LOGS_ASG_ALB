
resource "aws_cloudwatch_log_group" "asg_logs" {
  name              = "/ecs/asg/instance"
  retention_in_days = 14
}

resource "aws_iam_role" "ec2_cw_agent" {
  name = "ec2-cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Principal : { Service : "ec2.amazonaws.com" },
      Action : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.ec2_cw_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cw_agent_profile" {
  name = "ec2-cloudwatch-agent-profile"
  role = aws_iam_role.ec2_cw_agent.name
}



