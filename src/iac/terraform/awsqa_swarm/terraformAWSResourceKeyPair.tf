resource "aws_key_pair" "awsqa_swarm_key_pair" {
  key_name   = "awsqa_swarm_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

