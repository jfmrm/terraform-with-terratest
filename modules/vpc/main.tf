terraform {
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.25.0"
    }
  }
}

resource "random_id" "vpc" {
  keepers = {
    vpc_name = var.name
  }
  
  byte_length = 3
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.68.0"

  name = "${var.name}-${random_id.vpc.hex}"

  # defining static cidr for simplicity
  cidr = "10.0.1.0/24"

  # Single subnet architecture
  azs             = ["${var.region}a"]
  public_subnets = ["10.0.1.0/24"]
  private_subnets  = []

  # As we only have public subnet a nat gateway is not needed
  enable_nat_gateway = false
  enable_dns_hostnames = true

  tags = var.tags

}
