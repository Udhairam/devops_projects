# --- General ---

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Short project identifier used in resource names"
  default     = "devops"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev / staging / prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# --- Networking ---

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# --- Compute ---

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the web ASG"
  default     = "t3.micro"
}

variable "asg_min" {
  type        = number
  description = "Minimum number of instances in the ASG"
  default     = 1
}

variable "asg_desired" {
  type        = number
  description = "Desired number of instances in the ASG"
  default     = 1
}

variable "asg_max" {
  type        = number
  description = "Maximum number of instances in the ASG"
  default     = 3
}

# --- Storage ---

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for application data (must be globally unique)"
}

# --- Monitoring ---

variable "cpu_scale_out_threshold" {
  type        = number
  description = "CPU % above which the ASG scales out"
  default     = 75
}

variable "cpu_scale_in_threshold" {
  type        = number
  description = "CPU % below which the ASG scales in"
  default     = 25
}
