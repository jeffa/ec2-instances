variable "aws_credentials" {
  description = "Location of local AWS credentials file."
  type        = string
}

variable "id_rsa_path" {
  description = "Location of local public RSA file."
  type        = string
}

variable "aws_region" {
  description = "Physical cluster of data centers."
  type        = string
  default     = "us-east-1"
}

variable "ssh_security_group" {
  description = "ID of security group to allow ssh."
  type        = string
}

variable "http_security_group" {
  description = "ID of security group to allow http."
  type        = string
}

variable "servers" {
  description = "Servers to configure."
  type        = list(string)
  default     = ["aws_linux","debian","red_hat","suse","ubuntu"]
}

variable "instance_type" {
  description = "Type and size of instance."
  type        = string
  default     = "t2.micro"
}

