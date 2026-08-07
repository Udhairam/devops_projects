# --- Networking ---

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (one per AZ)"
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ)"
  value       = { for az, s in aws_subnet.private : az => s.id }
}

output "nat_gateway_ip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# --- Compute ---

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — use this to reach the app"
  value       = aws_lb.web.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web.arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "launch_template_id" {
  description = "Latest Launch Template ID"
  value       = aws_launch_template.web.id
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI used by the Launch Template"
  value       = data.aws_ami.amazon_linux_2023.id
}

# --- IAM ---

output "ec2_instance_role_arn" {
  description = "ARN of the EC2 IAM role (for SSM and CloudWatch access)"
  value       = aws_iam_role.ec2.arn
}

# --- Storage ---

output "app_bucket_name" {
  description = "S3 bucket name for application data"
  value       = aws_s3_bucket.app.bucket
}

output "app_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.app.arn
}

# --- Monitoring ---

output "cloudwatch_dashboard_url" {
  description = "Direct URL to the CloudWatch ops dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "log_group_name" {
  description = "CloudWatch log group for EC2 application logs"
  value       = aws_cloudwatch_log_group.web.name
}

# --- Secrets ---

output "app_secret_arn" {
  description = "ARN of the app secret in Secrets Manager"
  value       = aws_secretsmanager_secret.app.arn
}

output "app_secret_name" {
  description = "Name of the app secret — use this in aws secretsmanager get-secret-value"
  value       = aws_secretsmanager_secret.app.name
}

output "secrets_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt secrets"
  value       = aws_kms_key.secrets.arn
}
