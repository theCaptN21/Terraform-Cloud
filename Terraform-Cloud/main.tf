# ---root/main.tf ---

#Instance Module
module "Compute" {
  source         = "./Modules/Compute"
  elb            = module.LoadBalancer.elb
  alb_tg         = module.LoadBalancer.alb_tg
  private_subnet = module.Networking.private_subnet
  public_subnet  = module.Networking.public_subnet
  public_sg      = module.Networking.public_sg
  private_sg     = module.Networking.private_sg
  key_name       = "Terraform"
}

#Load Balancer Module
module "LoadBalancer" {
  source                 = "./Modules/LoadBalancer"
  vpc_id                 = module.Networking.vpc_id
  web_sg                 = module.Networking.web_sg
  public_subnet          = module.Networking.public_subnet
  database_asg           = module.Compute.database_asg
  tg_port                = 80
  tg_protocol            = "HTTP"
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 80
  listener_protocol      = "HTTP"
}

#VPC Module
module "Networking" {
  source        = "./Modules/Networking"
  vpc_cidr      = "10.0.0.0/16"
  access_ip     = var.access_ip
  private_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  region        = var.main_region
}
