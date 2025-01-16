locals {
  aws_linux_server = [for name in var.servers : name if name == "aws_linux"]
}

module "aws_linux" {
    source          = "./modules/aws_linux"
    instance_type   = var.instance_type
    ssh_rsa         = file(var.id_rsa_path)
    security_groups = [var.ssh_security_group, var.http_security_group]
    ami             = "ami-06b21ccaeff8cd686"
    instance_name      = "Amazon-Linux"
    
    for_each = toset(local.aws_linux_server)
}

output "aws_linux_ssh" {
    value = length(module.aws_linux) > 0 ? module.aws_linux["aws_linux"].public_ip : ""
}
