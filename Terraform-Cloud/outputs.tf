# ---root/outputs.tf ---

output "alb_dns" {
  value = module.LoadBalancer.alb_dns
}