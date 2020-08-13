resource "aws_elb" "awsqa_elb_spark" {
  security_groups = [aws_security_group.awsqa_elb_spark_elb.id]
  instances = aws_instance.awsqa_elb_spark.*.id
  internal = false
  listener {
    lb_port           = 8080
    lb_protocol       = "http"
    instance_port     = 8080
    instance_protocol = "http"
  }
  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 600
  name = "elb-spark"
  provisioner "local-exec" {
    command = "aws elb wait any-instance-in-service --region us-east-1 --load-balancer-name elb-spark"
  }
}
