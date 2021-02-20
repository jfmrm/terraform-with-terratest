resource "random_id" "security_group" {
  keepers = {
    security_group = var.name
  }
  
  byte_length = 3
}


resource "aws_security_group" "allow_alb" {
  name        = "allow-internet-traffic-${random_id.security_group.hex}"
  description = "Allows internet traffic to hit alb"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allows connection to LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "random_id" "lb" {
  keepers = {
    security_group = var.name
  }
  
  byte_length = 3
}

module "loadbalancer" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "${var.name}-${random_id.lb.hex}"
  instance_count         = 1
  iam_instance_profile   = var.instance_profile_name

  ami                    = var.ami
  instance_type          = var.instance_type
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_alb.id]
  subnet_ids              = var.subnets_ids
  associate_public_ip_address = true

  tags = var.tags
}
