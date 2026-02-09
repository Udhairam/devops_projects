terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name (must be globally unique)"
}

resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}