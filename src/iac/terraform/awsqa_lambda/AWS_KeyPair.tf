resource "aws_key_pair" "awsqa_lambda_key_pair" {
  key_name   = "awsqa_lambda_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

