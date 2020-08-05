output "mysql_dns" {
  value = [aws_instance.awsqa_elb_mysql.*.public_dns]
}

output "spark_dns" {
  value = [aws_instance.awsqa_elb_spark.*.public_dns]
}

output "spark_elb_dns" {
  value = [aws_elb.awsqa_elb_spark.dns_name]
}

