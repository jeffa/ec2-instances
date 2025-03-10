locals {
  suse_server = [for name in var.servers : name if name == "suse"]
}

module "suse" {
    source          = "./modules/suse"
    instance_type   = var.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-0cd60fd97301e4b49"
    instance_name      = "SUSE-Linux"

    for_each = toset(local.suse_server)
}

output "suse_user" {
    value = length(module.suse) > 0 ? module.suse["suse"].username : ""
}

output "suse_ssh" {
    value = length(module.suse) > 0 ? module.suse["suse"].public_ip : ""
}
