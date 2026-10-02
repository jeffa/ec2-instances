locals {
  server_matrix = {
    aws_linux = {
      ami           = "ami-0d27e0fb3bac4d724"
      username      = "ec2-user"
      instance_name = "Amazon-Linux"
    }
    debian = {
      ami           = "ami-0b75f821522bcff85"
      username      = "admin"
      instance_name = "Debian"
    }
    red_hat = {
      ami           = "ami-00adafae70b8029d8"
      username      = "ec2-user"
      instance_name = "Red-Hat"
    }
    suse = {
      ami           = "ami-0b12a86a613a04fc6"
      username      = "ec2-user"
      instance_name = "SUSE-Linux"
    }
    ubuntu = {
      ami           = "ami-0b6d9d3d33ba97d99"
      username      = "ubuntu"
      instance_name = "Ubuntu"
    }
  }

  selected_servers = {
    for name, config in local.server_matrix : name => config
    if contains(var.servers, name)
  }
}

module "server" {
  source   = "./modules/ec2_instance"
  for_each = local.selected_servers

  instance_type   = var.instance_type
  ssh_rsa         = file(var.id_rsa_path)
  security_groups = [var.ssh_security_group, var.http_security_group]
  ami             = each.value.ami
  username        = each.value.username
  instance_name   = each.value.instance_name
}

moved {
  from = module.aws_linux["aws_linux"]
  to   = module.server["aws_linux"]
}

moved {
  from = module.debian["debian"]
  to   = module.server["debian"]
}

moved {
  from = module.red_hat["red_hat"]
  to   = module.server["red_hat"]
}

moved {
  from = module.suse["suse"]
  to   = module.server["suse"]
}

moved {
  from = module.ubuntu["ubuntu"]
  to   = module.server["ubuntu"]
}

output "aws_linux_user" {
  value = try(module.server["aws_linux"].username, "")
}

output "aws_linux_ssh" {
  value = try(module.server["aws_linux"].public_ip, "")
}

output "debian_user" {
  value = try(module.server["debian"].username, "")
}

output "debian_ssh" {
  value = try(module.server["debian"].public_ip, "")
}

output "red_hat_user" {
  value = try(module.server["red_hat"].username, "")
}

output "red_hat_ssh" {
  value = try(module.server["red_hat"].public_ip, "")
}

output "suse_user" {
  value = try(module.server["suse"].username, "")
}

output "suse_ssh" {
  value = try(module.server["suse"].public_ip, "")
}

output "ubuntu_user" {
  value = try(module.server["ubuntu"].username, "")
}

output "ubuntu_ssh" {
  value = try(module.server["ubuntu"].public_ip, "")
}
