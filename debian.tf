locals {
  debian_servers = [for name in var.server : name if name == "debian"]
}

module "debian" {
    source          = "./modules/debian"
    instance_type   = local.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-064519b8c76274859"
    username        = "admin"
    servername      = "Debian"

    for_each = toset(local.debian_servers)
}

output "debian_ssh" {
    value = length(module.debian) > 0 ? module.debian["debian"].public_ip : ""
}
