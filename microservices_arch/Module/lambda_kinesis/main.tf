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

data "archive_file" "archive" {
  type        = "zip"
  source {
    content = templatefile("${path.module}/lambda_kinesis_to_dynamo.py", { api_url_complete = var.api_url_complete })
    filename = "lambda_kinesis_to_dynamo.py"
  }
  output_path = "${path.module}/outputs/lambda_kinesis_to_dynamo_payload.zip"
}

resource "aws_lambda_function" "lambda_kinesis_to_dynamo" {
  filename      = data.archive_file.archive.output_path
  function_name = "lambda_kinesis_to_dynamo"
  role          = aws_iam_role.iam_for_lambda_kinesis.arn
  handler       = "lambda_kinesis_to_dynamo.kinesis_to_dynamo_handler"

  runtime = "python3.8"
}