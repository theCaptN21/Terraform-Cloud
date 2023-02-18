variable "tg_protocol" {
  default = "HTTP"
}

variable "tg_port" {
  default = 80
}

variable "listener_protocol" {
  default = "HTTP"
}

variable "listener_port" {
  default = 80
}

variable "vpc_id" {}
variable "database_asg" {}
variable "public_subnet" {}
variable "web_sg" {}