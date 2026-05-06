output "vpc_id" {
  value = aws_vpc.vpc-1.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "web_instance_id" {
  value = aws_instance.web.id
}

output "web_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the web EC2 instance"
}

output "web_public_dns" {
  value       = aws_instance.web.public_dns
  description = "Public DNS of the web EC2 instance"
}
