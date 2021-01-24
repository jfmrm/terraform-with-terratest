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

module "ec2_instance" {
  source = "../modules/ec2"

  image_name = "ami-ubuntu-18.04-1.16.0-00-1569343567"
  virtualization_type = "hvm"
  instance_type = "t3.micro"
  ami_owner = "596934304958"
  tags = {
    Name = "Flugel"
    Owner = "InfraTeam"
  }
}
