variable "name" {
  type = string
  description = "vpc name"
}

variable "region" {
  type = string
  description = "valid aws region"
}

variable "tags" {
  type = map(string)
  description = "tags to be attached to the vpc"
  default = {}
}
