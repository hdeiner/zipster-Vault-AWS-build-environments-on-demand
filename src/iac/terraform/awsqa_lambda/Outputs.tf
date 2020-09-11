output "mysql_dns" {
  value = [aws_instance.awsqa_lambda_mysql.*.public_dns]
}

output "zipster_url" {
  value = "${aws_api_gateway_deployment.awsqa_lambda_api_gateway_deployment.invoke_url}${aws_api_gateway_resource.awsqa_lambda_api_gateway.path}"
}

