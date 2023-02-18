variable "public_subnet" {}
variable "private_subnet" {}
variable "elb" {}
variable "key_name" {}
variable "alb_tg" {}
variable "private_sg" {}
variable "public_sg" {}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "database_instance_type" {
  type    = string
  default = "db.t3.micro"
}