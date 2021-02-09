terraform {
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.25.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"
  
  name = "my_test_vpc"
  region = var.region
}

module "alb_instance_profile" {
  source = "../../modules/ec2-instance-linked-profile"

  name = "alb-instance-profile"
  allow_actions = ["ec2:Describe*"]
}

module "alb" {
  source = "../../modules/loadbalancer"

  name = "tags-web-server-lb"
  instance_profile_name = module.alb_instance_profile.name
  ami = "ami-063074c065d169d34"
  instance_type = "t2.micro"
  subnets_ids = module.vpc.public_subnets_ids
  vpc_id = module.vpc.id

  tags = {
    Name = "loadbalancer"
  }
}

module "tags_web_server_instance_profile" {
  source = "../../modules/ec2-instance-linked-profile"

  name = "tags_web_server"
  allow_actions = ["ec2:DescribeTags"]
}

module "tags_cluster" {
  source = "../../modules/ec2-cluster"

  instance_profile_name = module.tags_web_server_instance_profile.name
  cluster_name = "tags-cluster"
  instance_count = 2
  ami = "ami-0b3aa768814f8f6b3"
  subnets_ids = module.vpc.public_subnets_ids
  vpc_id = module.vpc.id
  instance_type = "t2.micro"
  lb_security_group = module.alb.security_group_id
  
  tags = {
    Name = "Flugel"
    Owner = "InfraTeam"
    App = "tags-web-server"
  }
}
