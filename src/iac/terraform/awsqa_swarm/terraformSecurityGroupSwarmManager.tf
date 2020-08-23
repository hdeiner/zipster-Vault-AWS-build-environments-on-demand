resource "aws_security_group" "awsqa_swarm_swarm_manager" {
  name        = "AWSQA-SWARM Spark Swarm Manager Security Group"
  description = "AWSQA-SWARM Spark Swarm Manager Security Group"
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
    from_port = 8080
    to_port   = 8080
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress { # cluster management communications
    protocol  = "tcp"
    from_port = 2377
    to_port   = 2377
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress { # communication among nodes
    protocol  = "tcp"
    from_port = 7946
    to_port   = 7946
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress { # communication among nodes
    protocol  = "udp"
    from_port = 7946
    to_port   = 7946
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress { # overlay network traffic
    protocol  = "tcp"
    from_port = 4789
    to_port   = 4789
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress { # overlay network traffic
    protocol  = "udp"
    from_port = 4789
    to_port   = 4789
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
    Name = "AWSQA-SWARM Spark Swarm Manager Security Group"
  }
}

