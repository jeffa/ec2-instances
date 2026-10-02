resource "aws_instance" "host" {
    ami           = var.ami
    instance_type = var.instance_type

    user_data = <<-EOF
        #!/bin/bash
        echo "${var.ssh_rsa}" > /home/${var.username}/.ssh/authorized_keys
        EOF

    vpc_security_group_ids = var.security_groups
    tags = {
        Name = var.instance_name
    }

    provisioner "local-exec" {
      command = "for attempt in $(seq 1 30); do if ssh-keyscan -T 5 -H ${self.public_ip} 2>/dev/null | grep -q .; then ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts; exit 0; fi; sleep 2; done; echo 'SSH did not become ready before the timeout' >&2; exit 1"
    }

    provisioner "local-exec" {
      command = "echo ${var.instance_name} id=${self.id} ansible_host=${self.public_ip} ansible_user=${var.username} >> /etc/ansible/hosts"
    }

    provisioner "local-exec" {
      command = "sed -i \"\" '/${self.id}/d' /etc/ansible/hosts"
      when = destroy
    }
}

