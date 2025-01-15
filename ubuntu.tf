locals {
  ubuntu_server = [for name in var.servers : name if name == "ubuntu"]
}

module "ubuntu" {
    source          = "./modules/ubuntu"
    instance_type   = local.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-0866a3c8686eaeeba"
    username        = "ubuntu"
    instance_name      = "Ubuntu"

    for_each = toset(local.ubuntu_server)
}

output "ubuntu_ssh" {
    value = length(module.ubuntu) > 0 ? module.ubuntu["ubuntu"].public_ip : ""
}
