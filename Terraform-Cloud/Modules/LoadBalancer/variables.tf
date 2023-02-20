variable "tg_port" {}
variable "tg_protocol" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "vpc_id" {}
variable "database_asg" {}
variable "public_subnet" {}
variable "web_sg" {}

variable "listener_protocol" {
  default = "HTTP"
}

variable "listener_port" {
  default = 80
}
