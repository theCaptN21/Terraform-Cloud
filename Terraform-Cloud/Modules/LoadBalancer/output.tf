output "alb_dns" {
  value = aws_lb.tfcloud_lb.dns_name
}

output "alb_tg" {
  value = aws_lb_target_group.tfcloud_tg.arn
}

output "elb" {
  value = aws_lb.tfcloud_lb.id
}
