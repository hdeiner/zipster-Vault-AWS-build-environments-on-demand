resource "aws_lambda_function" "awsqa_lambda_lambda_function" {
  runtime       = var.lambda_runtime
  environment {
    variables = {
      VAULT_ADDRESS = format("http://%s:8200",trimspace(file("../vault/.vault_dns")))
      VAULT_TOKEN = trimspace(file("../../../scripts/runAWS/.vault_howardeiner/root_token"))
      ENVIRONMENT = var.environment
    }
  }
  filename      = var.lambda_payload_filename
  source_code_hash = filebase64sha256(var.lambda_payload_filename)
  function_name = "zipster"

  handler = var.lambda_function_handler
  timeout = 60
  memory_size = 256
  role             = aws_iam_role.awsqa_lambda_iam_role.arn
  depends_on   = [aws_cloudwatch_log_group.awsqa_lambda_cloudwatch_log_group]

}

resource "aws_lambda_permission" "awsqa_lambda_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.awsqa_lambda_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.awsqa_lambda_api_gateway_deployment.execution_arn}/*/*"
}

