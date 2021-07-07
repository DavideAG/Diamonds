variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "aws_default_profile" {
    description = "Default AWS profile." 
    default     = "default"
}

variable "api_url_complete" {
    description = "API gateway diamond url" 
    type        = string
}

variable "dynamodb_prediction_table" {
  description = "The name of the DynamoDB table that stores the predictions"
  type        = string
}

variable "kinesis_stream_arn" {
  description = "kinesis stream arn"
  type        = string
}