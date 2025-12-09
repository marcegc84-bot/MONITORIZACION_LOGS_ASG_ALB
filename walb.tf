# Load Balancer
# ------------------------
resource "aws_lb" "alb_virginia" {
  name               = "alb-virg-${local.sufix}"
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg_alb.id]
  subnets = aws_subnet.public_subnet[*].id

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "alb"
    enabled = true
  }
}

resource "aws_lb_target_group" "tg_alb" {
  name        = "tg-alb-${local.sufix}"
  port        = var.ingress_ports_list[0]
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_virginia.id

  health_check {
    path = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb_virginia.arn
  port              = var.ingress_ports_list[0]
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_alb.arn
  }
}

# Launch Template
# ------------------------
resource "aws_launch_template" "template_virgina" {
  name_prefix   = "lt-virginia-${local.sufix}"
  image_id      = var.ec2_specs.ami
  instance_type = var.ec2_specs.instance_type
  #user_data = filebase64("userdata_nginx.sh")
  user_data = base64encode(templatefile("${path.module}/userdata_nginx.sh", {
  log_group = module.cw_logs.log_group_name
}))

  network_interfaces {
    security_groups = [aws_security_group.sg_asg.id]
  }
  iam_instance_profile {
    name = module.cw_logs.instance_profile_name
  }
}

# Auto Scaling Group
# ------------------------
resource "aws_autoscaling_group" "asg_alb" {
  name                      = "asg_alb-${local.sufix}"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.public_subnet[*].id
  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = aws_launch_template.template_virgina.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg_alb.arn]

  tag {
    key                 = "asg"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}


#Logs del ALB
#--------------------------------------------------------------

#Crear un bucket S3 para logs del ALB
resource "aws_s3_bucket" "alb_logs" {
  bucket = "alb-logs-${local.s3-sufix}"
  #bucket = "alb-logs-${var.tags.proyecto}${random_string.sufijo-s3.id}"
  
}

#Bloqueo el acceso publico
#--------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Permitir que el ALB escriba en el bucket
#-------------------------------------------------------------

data "aws_elb_service_account" "this" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = data.aws_elb_service_account.this.arn
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

