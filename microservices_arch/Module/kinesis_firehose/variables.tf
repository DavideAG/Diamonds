variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "aws_default_profile" {
    description = "Default AWS profile." 
    default     = "default"
}

variable "diamond_bucket" {
  type = string
}

variable "kinesis_stream_arn" {
  type = string
}

variable "kinesis_stream_name" {
  type = string
}