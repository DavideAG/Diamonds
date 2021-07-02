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

module "kinesis_firehose" {
  source = "./Module/kinesis_firehose"
  
  diamond_bucket = module.s3_bucket.s3_arn
}