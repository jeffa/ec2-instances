locals {
  suse_servers = [for name in var.server : name if name == "suse"]
}

module "suse" {
    source          = "./modules/suse"
    instance_type   = local.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-0cd60fd97301e4b49"
    servername      = "SUSE-Linux"

    for_each = toset(local.suse_servers)
}

output "suse_ssh" {
    value = length(module.suse) > 0 ? module.suse["suse"].public_ip : ""
}
