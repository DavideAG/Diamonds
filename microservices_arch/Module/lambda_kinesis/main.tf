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

resource "aws_iam_policy" "dynamo_policy" {
  name        = "dynamo-policy"
  description = "A full access DynamoDB policy"

  policy = file("${path.module}/dynamodb_full_access.policy")
}

# DynamoDB policy attachment
resource "aws_iam_role_policy_attachment" "dynamodb_policy_attach" {
  role       = aws_iam_role.iam_for_lambda_kinesis.name
  policy_arn = aws_iam_policy.dynamo_policy.arn
}

# Kinesis data stream policy attachment
resource "aws_iam_role_policy_attachment" "kinesis_stream_policy_attach" {
  role = aws_iam_role.iam_for_lambda_kinesis.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

data "archive_file" "archive" {
  type        = "zip"
  source {
    content = templatefile("${path.module}/lambda_kinesis_to_dynamo.py", { api_url_complete = var.api_url_complete, dynamodb_prediction_table = var.dynamodb_prediction_table })
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

resource "aws_lambda_event_source_mapping" "kinesis_stream_source_mapping" {
  event_source_arn  = var.kinesis_stream_arn
  function_name     = aws_lambda_function.lambda_kinesis_to_dynamo.arn
  starting_position = "LATEST"
}