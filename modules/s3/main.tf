resource "random_id" "bucket" {
  keepers = {
    bucket_name = var.bucket_name
  }
  
  byte_length = 3
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${random_id.bucket.hex}"
  acl    = var.acl

  tags = var.tags
}
