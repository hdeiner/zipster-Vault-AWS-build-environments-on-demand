resource "aws_instance" "awsqa_swarm_spark_swarm_worker" {
  count           = 2
  ami             = "ami-759bc50a"
  instance_type   = "t2.small"
  key_name        = aws_key_pair.awsqa_swarm_key_pair.key_name
  security_groups = [aws_security_group.awsqa_swarm_spark_worker.name]
  tags = {
    Name = "AWSQA-SWARM Spark Swarm Worker ${format("%03d", count.index)}"
  }
#  provisioner "local-exec" {     # I want to do this for each instance, but I get cycle errors from terraform
#    command = "echo self.availability_zone=${self.availability_zone} && aws ec2 wait instance-status-ok --region ${regex("[a-z]+[^a-z][a-z]+[^a-z][0-9]+",self.availability_zone)} --instance-ids ${aws_instance.awsqa_swarmspark[count.index].id}"
#  }
  provisioner "local-exec" { # instead, we do this brain dead thing
    command = "sleep 3m"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "../_scripts/provision_spark_swarm_worker.sh"
    destination = "/home/ubuntu/provision_spark_swarm_worker.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "chmod +x /home/ubuntu/provision_spark_swarm_worker.sh",
      "/home/ubuntu/provision_spark_swarm_worker.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${var.environment} > .environment"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = ".environment"
    destination = "/home/ubuntu/.environment"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "mkdir -p /home/ubuntu/.aws",
    ]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/config"
    destination = "/home/ubuntu/.aws/config"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "~/.aws/credentials"
    destination = "/home/ubuntu/.aws/credentials"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "../vault/.vault_dns"
    destination = "/home/ubuntu/.vault_dns"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "../_scripts/run_spark_swarm_worker.sh"
    destination = "/home/ubuntu/run_spark_swarm_worker.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "chmod +x /home/ubuntu/run_spark_swarm_worker.sh",
      "/home/ubuntu/run_spark_swarm_worker.sh"
    ]
  }
}

