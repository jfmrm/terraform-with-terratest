variable "bucket_name" {
  type = string
  description = "bucket unique name"
}

variable "acl" {
  type = string
  description = "bucket acl"
}

variable "tags" {
  type = map(string)
  description = "bucket tags"
}
