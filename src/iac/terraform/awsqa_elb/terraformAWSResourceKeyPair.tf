resource "aws_key_pair" "awsqa_elb_key_pair" {
  key_name   = "awsqa_elb_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

