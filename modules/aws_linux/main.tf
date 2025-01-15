resource "aws_instance" "host" {
    ami           = var.ami
    instance_type = var.instance_type

    user_data = <<-EOF
        #!/bin/bash
        echo "${var.ssh_rsa}" > /home/${var.username}/.ssh/authorized_keys
        EOF

    vpc_security_group_ids = var.security_groups
    tags = {
        Name = var.servername
    }

    provisioner "local-exec" {
      command = "sleep 60; ssh-keyscan ${self.public_ip} >> ~/.ssh/known_hosts"
    }

    provisioner "local-exec" {
      command = "echo ${var.servername} id=${self.id} ansible_host=${self.public_ip} ansible_user=${var.username} >> /etc/ansible/hosts"
    }

    provisioner "local-exec" {
      command = "sleep $((RANDOM % 20)); sed -i \"\" '/${self.id}/d' /etc/ansible/hosts"
      when = destroy
    }
}

