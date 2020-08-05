resource "aws_elb" "awsqa_elb_spark" {
  security_groups = [aws_security_group.awsqa_elb_spark_elb.id]
#  instances = aws_instance.awsqa_elb_spark.*.id  you should be able to do this, but https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb_attachment says that because of a current terraform issue to rely on the aws_elb_attachment only for now
  internal = false
  listener {
    lb_port           = 8080
    lb_protocol       = "http"
    instance_port     = 8080
    instance_protocol = "http"
  }
  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  name = "elb-spark"
}

resource "aws_elb_attachment" "spark000" {
  elb      = aws_elb.awsqa_elb_spark.id
  instance = aws_instance.awsqa_elb_spark[000].id
}

resource "aws_elb_attachment" "spark001" {
  elb      = aws_elb.awsqa_elb_spark.id
  instance = aws_instance.awsqa_elb_spark[001].id
}