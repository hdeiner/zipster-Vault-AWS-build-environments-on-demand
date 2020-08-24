resource "aws_instance" "awsqa_swarm_spark_swarm_manager" {
  count           = 1
  ami             = "ami-759bc50a"
  instance_type   = "t2.small"
  key_name        = aws_key_pair.awsqa_swarm_key_pair.key_name
  security_groups = [aws_security_group.awsqa_swarm_swarm_manager.name]
  tags = {
    Name = "AWSQA-SWARM Spark Swarm Manager ${format("%03d", count.index)}"
  }
#  provisioner "local-exec" {     # I want to do this for each instance, but I get cycle errors from terraform
#    command = "echo self.availability_zone=${self.availability_zone} && aws ec2 wait instance-status-ok --region ${regex("[a-z]+[^a-z][a-z]+[^a-z][0-9]+",self.availability_zone)} --instance-ids ${aws_instance.awsqa_swarmspark[count.index].id}"
#  }
  provisioner "local-exec" { # instead, we do this brain dead thing
    command = "sleep 3m"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo hostname manager-${format("%03d",count.index)}"
    ]
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "../_scripts/provision_spark_swarm_manager.sh"
    destination = "/home/ubuntu/provision_spark_swarm_manager.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "chmod +x /home/ubuntu/provision_spark_swarm_manager.sh",
      "/home/ubuntu/provision_spark_swarm_manager.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo aws_instance.awsqa_swarm_spark_swarm_worker[count.index].count > .inital_swarm_worker_count"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = ".inital_swarm_worker_count"
    destination = "/home/ubuntu/.inital_swarm_worker_count"
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
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "../../docker-compose/use_spark_swarm.yml"
    destination = "/home/ubuntu/use_spark_swarm.yml"
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
    source = "../../docker-compose/use_portainer_swarm.yml"
    destination = "/home/ubuntu/use_portainer_swarm.yml"
  }
  provisioner "file" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    source = "../_scripts/run_spark_swarm_manager.sh"
    destination = "/home/ubuntu/run_spark_swarm_manager.sh"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_dns
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "chmod +x /home/ubuntu/run_spark_swarm_manager.sh",
      "/home/ubuntu/run_spark_swarm_manager.sh"
    ]
  }
}

