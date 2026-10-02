resource "local_file" "ansible_inventory" {
  filename = pathexpand(var.ansible_inv_path)

  content = trimspace(join("\n", compact([
    length(module.server) > 0 && contains(keys(module.server), "aws_linux") ? "aws_linux ansible_host=${module.server["aws_linux"].public_ip} ansible_user=${module.server["aws_linux"].username} ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'" : "",
    length(module.server) > 0 && contains(keys(module.server), "debian") ? "debian ansible_host=${module.server["debian"].public_ip} ansible_user=${module.server["debian"].username} ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'" : "",
    length(module.server) > 0 && contains(keys(module.server), "red_hat") ? "red_hat ansible_host=${module.server["red_hat"].public_ip} ansible_user=${module.server["red_hat"].username} ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'" : "",
    length(module.server) > 0 && contains(keys(module.server), "suse") ? "suse ansible_host=${module.server["suse"].public_ip} ansible_user=${module.server["suse"].username} ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'" : "",
    length(module.server) > 0 && contains(keys(module.server), "ubuntu") ? "ubuntu ansible_host=${module.server["ubuntu"].public_ip} ansible_user=${module.server["ubuntu"].username} ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'" : "",
  ])))

  file_permission = "0644"
}
