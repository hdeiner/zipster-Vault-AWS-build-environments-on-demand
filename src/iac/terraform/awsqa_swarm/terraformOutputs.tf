output "mysql_dns" {
  value = [aws_instance.awsqa_swarm_mysql.*.public_dns]
}

output "spark_swarm_worker_dns" {
  value = [aws_instance.awsqa_swarm_spark_swarm_worker.*.public_dns]
}

output "spark_swarm_manager_dns" {
  value = [aws_instance.awsqa_swarm_spark_swarm_manager.*.public_dns]
}

