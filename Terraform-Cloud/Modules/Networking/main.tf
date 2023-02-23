provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

#VPC

resource "aws_vpc" "tfcloud_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tfcloud_project_vpc-${random_integer.random.id}"
  }
}

resource "random_integer" "random" {
  min = 1
  max = 50
}

#Gateways & EIP

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.tfcloud_vpc.id
}

resource "aws_eip" "tfcloud_eip" {
  vpc = true
}

resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.tfcloud_eip.id
  subnet_id     = aws_subnet.tfcloud_public_subnet[1].id
}

#Subnets

resource "aws_subnet" "tfcloud_public_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.tfcloud_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tfcloud_public_${count.index + 1}"
  }
}

resource "aws_subnet" "tfcloud_private_subnet" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.tfcloud_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tfcloud_private_${count.index + 1}"
  }

}

#Route Tables & Associations

resource "aws_route_table" "PubRT_rt" {
  vpc_id = aws_vpc.tfcloud_vpc.id

  tags = {
    Name = "tfcloud_public"
  }
}

resource "aws_route_table" "PriRT_rt" {
  vpc_id = aws_vpc.tfcloud_vpc.id

  tags = {
    Name = "tfcloud_private"
  }
}

resource "aws_default_route_table" "PriRT_rt" {
  default_route_table_id = aws_vpc.tfcloud_vpc.default_route_table_id
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.PubRT_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id
}


resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.PriRT_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.NATgw.id
}


resource "aws_route_table_association" "PubRT_association" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.tfcloud_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.PubRT_rt.id
}

resource "aws_route_table_association" "PriRT_association" {
  count          = length(var.private_cidrs)
  subnet_id      = aws_subnet.tfcloud_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.PriRT_rt.id
}

#Security Groups

resource "aws_security_group" "tfcloud_web_sg" {
  name        = "tfcloud_web_sg"
  description = "Allow HTTP & HTTPS traffic"
  vpc_id      = aws_vpc.tfcloud_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tfcloud_private_sg" {
  name        = "tfcloud_rds_sg"
  description = "Allow SQL access to port 3306"
  vpc_id      = aws_vpc.tfcloud_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.tfcloud_public_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.tfcloud_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tfcloud_public_sg" {
  name        = "Allow_SSH_sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.tfcloud_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
