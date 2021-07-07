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
  type                    = "AWS"
  uri                     = var.sagemaker_lambda.invoke_arn

  request_templates = {
      "application/json" = <<REQUEST_TEMPLATE
{
  "depth": "$input.params('depth')",
  "table": "$input.params('table')",
  "price": "$input.params('price')",
  "x": "$input.params('x')",
  "y": "$input.params('y')",
  "z": "$input.params('z')",
  "cut_Fair": "$input.params('cut_Fair')",
  "cut_Good": "$input.params('cut_Good')",
  "cut_Ideal": "$input.params('cut_Ideal')",
  "cut_Premium": "$input.params('cut_Premium')",
  "cut_Very Good": "$input.params('cut_Very Good')",
  "color_D": "$input.params('color_D')",
  "color_E": "$input.params('color_E')",
  "color_F": "$input.params('color_F')",
  "color_G": "$input.params('color_G')",
  "color_H": "$input.params('color_H')",
  "color_I": "$input.params('color_I')",
  "color_J": "$input.params('color_J')",
  "clarity_I1": "$input.params('clarity_I1')",
  "clarity_IF": "$input.params('clarity_IF')",
  "clarity_SI1": "$input.params('clarity_SI1')",
  "clarity_SI2": "$input.params('clarity_SI2')",
  "clarity_VS1": "$input.params('clarity_VS1')",
  "clarity_VS2": "$input.params('clarity_VS2')",
  "clarity_VVS1": "$input.params('clarity_VVS1')",
  "clarity_VVS2": "$input.params('clarity_VVS2')"
}
  REQUEST_TEMPLATE
  }

}

resource "aws_api_gateway_method_response" "diamond_method_response" {
  rest_api_id = aws_api_gateway_rest_api.diamond_rest_api.id
  resource_id = aws_api_gateway_resource.diamond_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "diamond_integration_response" {
  depends_on  = [aws_api_gateway_integration.diamond_integration]
  rest_api_id = aws_api_gateway_rest_api.diamond_rest_api.id
  resource_id = aws_api_gateway_resource.diamond_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.diamond_method_response.status_code
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
