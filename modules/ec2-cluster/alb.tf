resource "random_id" "alb" {
  keepers = {
    alb = var.cluster_name
  }
  
  byte_length = 3
}

resource "aws_security_group" "alb_security_group" {
  name        = "alb-${var.cluster_name}-${random_id.alb.hex}-sg"
  description = "Allows alb to hit webserver running on cluster ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allows connection from the web"
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

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
  name = "alb-${var.cluster_name}-${random_id.alb.hex}"

  load_balancer_type = "application"

  vpc_id             = var.vpc_id
  subnets            = var.subnets_ids
  security_groups    = [aws_security_group.alb_security_group.id]

  target_groups = [
    {
      name             = "${var.cluster_name}-${random_id.alb.hex}"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "test" {
  count            = length(module.ec2_cluster.id)
  target_group_arn = module.alb.target_group_arns[0]
  target_id        = module.ec2_cluster.id[count.index]
  port             = 80
}
