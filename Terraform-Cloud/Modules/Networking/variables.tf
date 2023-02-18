variable "region" {
  type    = string
  default = "us-east-1"
}

variable "private_cidrs" {}
variable "public_cidrs" {}
variable "vpc_cidr" {}

variable "access_ip" {
  type = string
}

