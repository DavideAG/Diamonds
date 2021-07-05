variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "aws_default_profile" {
    description = "Default AWS profile." 
    default     = "default"
}

variable "tag_name" {
  default = "EC2-diamond"
}

variable "availability_zone" {
  default = "eu-west-1a"
}
