resource "aws_vpc" "vpc_virginia" {
  cidr_block = var.virginia_cidr
  tags = {
    "Name" = "vpc_virginia-${local.sufix}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.publicsubnets)
  vpc_id                  = aws_vpc.vpc_virginia.id
  cidr_block              = var.publicsubnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    #"Name" = "public_subnet-${local.sufix}"
    "Name" = "public-${var.azs[count.index]}-${local.sufix}"
  }

}

resource "aws_subnet" "private_subnet" {
  count      = length(var.privatesubnets)
  vpc_id     = aws_vpc.vpc_virginia.id
  cidr_block = var.privatesubnets[count.index]
  tags = {
    #"Name" = "private_subnet-${local.sufix}"
    "Name" = "public-${var.azs[count.index]}-${local.sufix}"
  }

  depends_on = [
    aws_subnet.public_subnet
  ]

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_virginia.id

  tags = {
    Name = "IGW vpc virginia-${local.sufix}"
  }
}

resource "aws_route_table" "public_crt" { #para que puedas salir a internet #public_crt (public custom route table)
  vpc_id = aws_vpc.vpc_virginia.id

  route {
    #cidr_block = "0.0.0.0/0"
    cidr_block = var.sg_ingress_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_crt-${local.sufix}"
  }
}

resource "aws_route_table_association" "crta_public_subnet" { #crta custom route table asociate
    count          = length(aws_subnet.public_subnet)
    #count          = length(var.publicsubnets)
    subnet_id      = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_crt.id
}

resource "aws_security_group" "sg_alb" {
  name        = "sg_alb-${local.sufix}"
  description = "Allow incoming HTTP traffic to ALB"
  vpc_id      = aws_vpc.vpc_virginia.id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [var.sg_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [var.sg_ingress_cidr]
  }

  tags = {
    Name = "sg-alb-${local.sufix}"
  }
}

resource "aws_security_group" "sg_asg" {
  name        = "sg_asg-${local.sufix}"
  description = "Allow traffic only from ALB"
  vpc_id      = aws_vpc.vpc_virginia.id

  ingress {
    description     = "Allow HTTP traffic only from the ALB SG"
    from_port       = var.ingress_ports_list[0]
    to_port         = var.ingress_ports_list[0]
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  # (opcional) permitir SSH desde tu IP
  ingress {
    description = "Allow SSH for admin"
    from_port   = var.ingress_ports_list[2]
    to_port     = var.ingress_ports_list[2]
    protocol    = "tcp"
    cidr_blocks = [var.sg_ingress_cidr] # Ej: ["X.X.X.X/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-asg-${local.sufix}"
  }
}

