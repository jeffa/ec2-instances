locals {
  red_hat_server = [for name in var.servers : name if name == "red_hat"]
}

module "red_hat" {
    source          = "./modules/red_hat"
    instance_type   = var.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-0583d8c7a9c35822c"
    instance_name      = "Red-Hat"

    for_each = toset(local.red_hat_server)
}

output "red_hat_ssh" {
    value = length(module.red_hat) > 0 ? module.red_hat["red_hat"].public_ip : ""
}
