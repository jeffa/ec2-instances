resource "local_file" "ansible_inventory" {
  filename = pathexpand(var.ansible_inv_path)

  content = trimspace(join("\n", compact([
    length(module.aws_linux) > 0 ? "aws_linux ansible_host=${module.aws_linux["aws_linux"].public_ip} ansible_user=${module.aws_linux["aws_linux"].username}" : "",
    length(module.debian) > 0 ? "debian ansible_host=${module.debian["debian"].public_ip} ansible_user=${module.debian["debian"].username}" : "",
    length(module.red_hat) > 0 ? "red_hat ansible_host=${module.red_hat["red_hat"].public_ip} ansible_user=${module.red_hat["red_hat"].username}" : "",
    length(module.suse) > 0 ? "suse ansible_host=${module.suse["suse"].public_ip} ansible_user=${module.suse["suse"].username}" : "",
    length(module.ubuntu) > 0 ? "ubuntu ansible_host=${module.ubuntu["ubuntu"].public_ip} ansible_user=${module.ubuntu["ubuntu"].username}" : "",
  ])))

  file_permission = "0644"
}
