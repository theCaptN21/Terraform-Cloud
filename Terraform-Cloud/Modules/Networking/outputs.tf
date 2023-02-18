output "vpc_id" {
  description = "The ID of the VPC"
  value       = "aws_vpc.tfcloud_vpc.id"
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = "module.tfcloud_vpc.default_security_group_id"
}

output "private_sg" {
  value = aws_security_group.tfcloud_private_sg.id
}

output "public_sg" {
  value = aws_security_group.tfcloud_public_sg.id
}

output "web_sg" {
  value = aws_security_group.tfcloud_web_sg.id
}

output "public_subnet" {
  value = aws_subnet.tfcloud_public_subnet[*].id
}

output "private_subnet" {
  value = aws_subnet.tfcloud_private_subnet[*].id
}