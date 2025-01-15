locals {
  ubuntu_servers = [for name in var.server : name if name == "ubuntu"]
}

module "ubuntu" {
    source          = "./modules/ubuntu"
    instance_type   = local.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-0866a3c8686eaeeba"
    username        = "ubuntu"
    servername      = "Ubuntu"

    for_each = toset(local.ubuntu_servers)
}

output "ubuntu_ssh" {
    value = length(module.ubuntu) > 0 ? module.ubuntu["ubuntu"].public_ip : ""
}
