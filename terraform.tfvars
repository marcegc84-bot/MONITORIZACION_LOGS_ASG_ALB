aws_region = "us-east-1"
virginia_cidr = "10.10.0.0/16"
publicsubnets = ["10.10.1.0/24", "10.10.2.0/24"]
privatesubnets = ["10.10.50.0/24", "10.10.51.0/24"]
tags = {
  "env"         = "Dev"
  "owner"       = "Marce"
  "cloud"       = "AWS"
  "IAC"         = "Terraform"
  "IAC_version" = "v1.12.2"
  "proyecto"    = "personal"
  "region"      = "North-Virg"
}
sg_ingress_cidr = "0.0.0.0/0"
ec2_specs = {
  "ami"           = "ami-0cbbe2c6a1bb2ad63"
  "instance_type" = "t2.micro"
}
azs = ["us-east-1a", "us-east-1b"]
ingress_ports_list = [80, 443, 22]