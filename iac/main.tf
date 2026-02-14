resource "aws_s3_bucket" "sample" {
  bucket = var.bucket_name
}

resource "aws_secretsmanager_secret" "app_secret" {
  name       = var.secret_name
  description = "Application secret managed by Terraform"
}

resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = var.secret_value
}