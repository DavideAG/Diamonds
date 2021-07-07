resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "diamond_firehose_read_policy" {
  name = "diamond_firehose_read_policy"

  //description = "Policy to allow reading from the ${var.stream_name} stream"
  role = aws_iam_role.firehose_role.id

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "kinesis:DescribeStream",
            "kinesis:GetShardIterator",
            "kinesis:GetRecords"
         ],
         "Resource":[
            "arn:aws:kinesis:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stream/${var.kinesis_stream_name}"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
         ],
         "Resource":[
            "${var.diamond_bucket}",
            "${var.diamond_bucket}/*"
         ]
      },
      {
        "Effect": "Allow",
        "Action": [
            "logs:PutLogEvents"
        ],
        "Resource": [
            "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:diamond_firehose_logging_group:log-stream:diamond_firehose_logging"
        ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "glue:GetTableVersions"
         ],
         "Resource":[
            "*"
         ]
      }
   ]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "diamond_firehose_delivery_stream" {
  name        = "diamond-firehose-delivery-stream"
  destination = "s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_stream_arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.diamond_bucket
    prefix = "data/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "diamond_firehose_logging_group"
      log_stream_name = "diamond_firehose_logging"
    }
  }

}