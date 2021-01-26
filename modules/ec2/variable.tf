variable "image_name" {
  type = string
  description = "aws image name i.e. ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "virtualization_type" {
  type = string
  description = "aws valid virtualization type i.e. hvm"
}

variable "instance_type" {
  type = string
  description = "aws valid instance type i.e t3.micro"
}

variable "tags" {
  type = map(string)
  description = "tags to attach on the ec2 instance"
}

variable "ami_owner" {
  type = string
  description = "account name that owns ami-image"
}
