variable "instance_type" {
  description = "Type and size of instance."
  type        = string
}

variable "security_groups" {
  description = "List of Security Group IDs to allow open ports."
  type        = list(string)
}

variable "ssh_rsa" {
  description = "The public key to inject into server's known hosts file."
  type        = string
}

variable "ami" {
  description = "The Amazon Machine Image ID."
  type        = string
}

variable "username" {
  description = "The name of default user on distro."
  type        = string
  default     = "ec2-user"
}

variable "instance_name" {
  description = "Tag Name to assign."
  type        = string
}
