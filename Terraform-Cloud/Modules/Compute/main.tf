data "aws_rds_engine_version" "test" {
  engine             = "mysql"
  preferred_versions = ["8.0.27"]
}

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

#DB Launch Template

resource "aws_launch_template" "tfcloud_rds" {
  name_prefix            = "tfcloud_rds"
  image_id               = data.aws_ami.linux.id
  instance_type          = var.database_instance_type
  vpc_security_group_ids = [var.private_sg]
  key_name               = var.key_name
  user_data              = filebase64("nginx.sh")

  tags = {
    Name = "tfcloud_rds_database"
  }
}

resource "aws_autoscaling_group" "tfcloud_rds" {
  name                = "tfcloud_rds"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 2
  max_size            = 5
  desired_capacity    = 3

  launch_template {
    id      = aws_launch_template.tfcloud_rds.id
    version = "$Latest"
  }
}

#Bastion Host Launch Template

resource "aws_launch_template" "tfcloud_bastion" {
  name_prefix            = "tfcloud_bastion"
  image_id               = data.aws_ami.linux.id
  instance_type          = var.bastion_instance_type
  vpc_security_group_ids = [var.public_sg]
  key_name               = var.key_name

  tags = {
    Name = "tfcloud_bastion"
  }
}

resource "aws_autoscaling_group" "tfcloud_bastion" {
  name                = "tfcloud_bastion"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 2
  max_size            = 5
  desired_capacity    = 3

  launch_template {
    id      = aws_launch_template.tfcloud_bastion.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.tfcloud_rds.id
  alb_target_group_arn   = var.alb_tg
}

