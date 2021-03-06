terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


module "EC2" {
  source = "./Module/EC2"
}

module "kinesis_stream" {
  source = "./Module/kinesis_stream"
}

module "s3_bucket" {
  source = "./Module/S3"
}

module "dynamodb" {
  source = "./Module/DynamoDB"
}

module "lambda_kinesis" {
  source = "./Module/lambda_kinesis"

  api_url_complete = module.api_gateway.complete_unvoke_url
  dynamodb_prediction_table = var.dynamodb_prediction_table
  kinesis_stream_arn = module.kinesis_stream.kinesis_stream_arn
}

module "lambda_sagemaker" {
  source = "./Module/lambda_sagemaker"
}

module "api_gateway" {
  source = "./Module/API_Gateway"

  sagemaker_lambda = module.lambda_sagemaker.sagemaker_lambda
}

module "kinesis_firehose" {
  source = "./Module/kinesis_firehose"
  
  kinesis_stream_name = module.kinesis_stream.kinesis_stream_name
  kinesis_stream_arn = module.kinesis_stream.kinesis_stream_arn
  diamond_bucket = module.s3_bucket.s3_arn
}