resource "aws_api_gateway_rest_api" "awsqa_lambda_api" {
  name        = "${var.environment} Lambda API"
  description = "${var.environment} Lambda API"
}

resource "aws_api_gateway_resource" "awsqa_lambda_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.awsqa_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.awsqa_lambda_api.root_resource_id
  path_part   = var.api_path
}

resource "aws_api_gateway_method" "awsqa_lambda_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.awsqa_lambda_api.id
  resource_id   = aws_api_gateway_resource.awsqa_lambda_api_gateway.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "awsqa_lambda_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.awsqa_lambda_api.id
  resource_id             = aws_api_gateway_resource.awsqa_lambda_api_gateway.id
  http_method             = aws_api_gateway_method.awsqa_lambda_gateway_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.awsqa_lambda_lambda_function.invoke_arn
}

# Unfortunately the proxy resource cannot match an empty path at the root of the API.
# To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "awsqa_lambda_aws_api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.awsqa_lambda_api.id
  resource_id   = aws_api_gateway_rest_api.awsqa_lambda_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "awsqa_lambda_api_gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.awsqa_lambda_api.id
  resource_id = aws_api_gateway_method.awsqa_lambda_aws_api_gateway_method.resource_id
  http_method = aws_api_gateway_method.awsqa_lambda_aws_api_gateway_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.awsqa_lambda_lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "awsqa_lambda_api_gateway_deployment" {
  depends_on  = [aws_api_gateway_integration.awsqa_lambda_gateway_integration]
  rest_api_id = aws_api_gateway_rest_api.awsqa_lambda_api.id
  stage_name  = var.api_env_stage_name
}