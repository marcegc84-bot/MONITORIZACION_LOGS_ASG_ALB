module "monitoring" {
  source = "./modules/monitoring"

  region     = "us-east-1" 
  alb_arn_suffix = aws_lb.alb_virginia.arn_suffix
  tg_arn_suffix  = aws_lb_target_group.tg_alb.arn_suffix
  asg_name       = aws_autoscaling_group.asg_alb.name
  alert_email    = "marcegc84@gmail.com"
}

module "cw_logs" {
  source = "./modules/cw_logs"
}