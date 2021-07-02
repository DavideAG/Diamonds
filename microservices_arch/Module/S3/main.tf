resource "aws_s3_bucket" "diamond_bucket" {
  bucket = "s3-diamond-bucket"
  acl    = "private"
}
