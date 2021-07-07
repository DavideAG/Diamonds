resource "aws_iam_role" "iam_for_lambda_sagemaker" {
  name = "iam_for_lambda_sagemaker"

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


resource "aws_iam_policy" "sagemaker_policy" {
  name        = "sagemaker-policy"
  description = "A sagemaker policy to invoke the endpoint"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sagemaker:InvokeEndpoint",
            "Resource": "arn:aws:sagemaker:eu-west-1:392050061436:endpoint/sagemaker-scikit-learn-2021-07-07-07-02-33-511"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sagemaker_policy_attach" {
  role       = aws_iam_role.iam_for_lambda_sagemaker.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}

data "archive_file" "archive" {
  type        = "zip"
  source_file = "${path.module}/lambda_rest_to_sagemaker.py"
  output_path = "${path.module}/outputs/lambda_rest_to_sagemaker_payload.zip"
}

resource "aws_lambda_function" "lambda_rest_to_sagemaker" {
  filename      = "${path.module}/outputs/lambda_rest_to_sagemaker_payload.zip"
  function_name = "lambda_rest_to_sagemaker"
  role          = aws_iam_role.iam_for_lambda_sagemaker.arn
  handler       = "lambda_rest_to_sagemaker.rest_to_sagemaker_handler"

  /* source_code_hash = filebase64sha256("lambda_function_payload.zip") */

  runtime = "python3.8"

  /* environment {
    variables = {
      foo = "bar"
    }
  } */
}

// check if it is needed to be triggered by the rest api gateway
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rest_to_sagemaker.function_name
  principal     = "apigateway.amazonaws.com"
}
