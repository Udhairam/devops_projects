variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name (must be globally unique)"
}
variable "secret_name" {
  type        = string
  description = "Name of the secret in AWS Secrets Manager"
}

variable "secret_value" {
  type        = string
  description = "Value of the secret"
  sensitive   = true
}