output "complete_unvoke_url"   {
    value = "${aws_api_gateway_deployment.diamond_deployment.invoke_url}${aws_api_gateway_stage.diamond_stage.stage_name}/${aws_api_gateway_resource.diamond_resource.path_part}"
}

output "lambda_invoke_url" {
    value = aws_api_gateway_stage.diamond_stage.invoke_url
}