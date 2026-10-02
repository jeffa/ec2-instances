variable "instance_type" {
  description = "Type and size of instance."
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs to allow open ports."
  type        = list(string)
}

variable "ssh_rsa" {
  description = "The public SSH key to inject into the server."
  type        = string
}

variable "ami" {
  description = "The Amazon Machine Image ID."
  type        = string
}

variable "username" {
  description = "The default login user on the image."
  type        = string
}

variable "instance_name" {
  description = "The Name tag to assign."
  type        = string
}
