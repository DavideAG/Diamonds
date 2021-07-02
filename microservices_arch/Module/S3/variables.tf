variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "aws_default_profile" {
    description = "Default AWS profile." 
    default     = "default"
}


output "s3_arn" {
  value = aws_s3_bucket.diamond_bucket.arn
}