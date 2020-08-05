resource "aws_security_group" "awsqa_elb_mysql" {
  name        = "AWSQA-ELB MySQL Security Group"
  description = "AWSQA-ELB MySQL Security Group"
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = {
    Name = "AWSQA-ELB MySQL Security Group"
  }
}

