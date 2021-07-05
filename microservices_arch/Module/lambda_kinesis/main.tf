resource "aws_iam_role" "iam_for_lambda_kinesis" {
  name = "iam_for_lambda_kinesis"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
/* TODO: check if we need to attach a policy like AmazonDynamoDBFullAccess */


data "archive_file" "archive" {
  type        = "zip"
  source_file = "${path.module}/lambda_kinesis_to_dynamo.py"
  output_path = "${path.module}/outputs/lambda_kinesis_to_dynamo_payload.zip"
}

resource "aws_lambda_function" "lambda_kinesis_to_dynamo" {
  filename      = "${path.module}/outputs/lambda_kinesis_to_dynamo_payload.zip"
  function_name = "lambda_kinesis_to_dynamo"
  role          = aws_iam_role.iam_for_lambda_kinesis.arn
  handler       = "lambda_kinesis_to_dynamo.kinesis_to_dynamo_handler"

  /* source_code_hash = filebase64sha256("lambda_function_payload.zip") */

  runtime = "python3.8"

  /* environment {
    variables = {
      foo = "bar"
    }
  } */
}