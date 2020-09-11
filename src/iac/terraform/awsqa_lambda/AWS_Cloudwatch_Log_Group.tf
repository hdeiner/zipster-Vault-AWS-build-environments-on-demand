resource "aws_cloudwatch_log_group" "awsqa_lambda_cloudwatch_log_group" {
  name = "${var.environment}_Zipster_API"
}

# allow lambda to log to cloudwatch
data "aws_iam_policy_document" "awsqa_lambda_cloudwatch_log_group_policy_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:::*",
    ]
  }
}