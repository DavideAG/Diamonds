resource "aws_api_gateway_rest_api" "diamond_rest_api" {
  description = "Diamond API Gateway"
  name        = "diamond_rest_api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "diamond_resource" {
  rest_api_id = aws_api_gateway_rest_api.diamond_rest_api.id
  parent_id   = aws_api_gateway_rest_api.diamond_rest_api.root_resource_id
  path_part   = "diamond"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id       = aws_api_gateway_rest_api.diamond_rest_api.id
  resource_id       = aws_api_gateway_resource.diamond_resource.id
  http_method       = "GET"
  authorization     = "NONE"
  api_key_required  = false
}

resource "aws_api_gateway_integration" "diamond_integration" {
  rest_api_id             = aws_api_gateway_rest_api.diamond_rest_api.id
  resource_id             = aws_api_gateway_resource.diamond_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.sagemaker_lambda.invoke_arn
}

# Deployment

resource "aws_api_gateway_deployment" "diamond_deployment" {
  depends_on = [aws_api_gateway_integration.diamond_integration]
  rest_api_id = aws_api_gateway_rest_api.diamond_rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.diamond_rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "diamond_stage" {
  deployment_id = aws_api_gateway_deployment.diamond_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.diamond_rest_api.id
  stage_name    = "diamond_stage"
}
