# --- KMS key for encrypting secrets at rest ---

resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager — ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = merge(local.common_tags, { Name = "${local.name_prefix}-secrets-kms" })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# --- Application secret ---

resource "aws_secretsmanager_secret" "app" {
  name                    = "${local.name_prefix}/app"
  description             = "Application credentials for ${local.name_prefix} (${var.environment})"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-app-secret" })
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    db_password = "changeme-before-apply"
    api_key     = "changeme-before-apply"
    environment = var.environment
  })

  # Prevent Terraform from overwriting manually rotated values after initial creation
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# --- IAM policy: allow EC2 to read this specific secret ---

data "aws_iam_policy_document" "secrets_read" {
  statement {
    sid    = "ReadAppSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = [aws_secretsmanager_secret.app.arn]
  }

  statement {
    sid    = "DecryptWithKMS"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [aws_kms_key.secrets.arn]
  }
}

resource "aws_iam_policy" "secrets_read" {
  name        = "${local.name_prefix}-secrets-read"
  description = "Allow EC2 instances to read ${local.name_prefix} app secret"
  policy      = data.aws_iam_policy_document.secrets_read.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "secrets_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.secrets_read.arn
}
