locals {
  debian_server = [for name in var.servers : name if name == "debian"]
}

module "debian" {
    source          = "./modules/debian"
    instance_type   = var.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-064519b8c76274859"
    username        = "admin"
    instance_name      = "Debian"

    for_each = toset(local.debian_server)
}

output "debian_ssh" {
    value = length(module.debian) > 0 ? module.debian["debian"].public_ip : ""
}
