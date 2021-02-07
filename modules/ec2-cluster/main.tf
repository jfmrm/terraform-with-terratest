terraform {
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.25.0"
    }
  }
}

resource "random_id" "ec2_cluster" {
  keepers = {
    cluster_name = var.cluster_name
  }
  
  byte_length = 3
}


module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "${var.cluster_name}-${random_id.ec2_cluster.hex}"
  instance_count         = var.instance_count
  iam_instance_profile   = var.instance_profile_name

  ami                    = var.ami
  instance_type          = var.instance_type
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_alb.id]
  subnet_ids              = var.subnets_ids

  tags = var.tags
}
