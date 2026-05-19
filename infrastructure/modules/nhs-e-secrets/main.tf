# NHS-E Secrets Module - Main configuration
# Provides IAM role, KMS key, and Secrets Manager for secure secret retrieval

# Data source for AWS account ID
data "aws_caller_identity" "current" {}

# KMS Customer Managed Key for encrypting secrets
resource "aws_kms_key" "nhs_e_secrets" {
  description             = "KMS key for NHS-E secrets encryption - ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_kms_key_rotation

  tags = {
    Name        = "nhs-e-secrets-key-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_kms_alias" "nhs_e_secrets" {
  name          = "alias/nhs-e-secrets-${var.environment}"
  target_key_id = aws_kms_key.nhs_e_secrets.key_id
}

# KMS Key Policy allowing NHS-E role to decrypt
data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow NHS-E Role to Decrypt"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.nhs_e_cross_account.arn]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "nhs_e_secrets" {
  key_id = aws_kms_key.nhs_e_secrets.id
  policy = data.aws_iam_policy_document.kms_policy.json
}

# IAM Role for NHS-E cross-account access
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.irs_role_arn]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["nhs-e-gom-${var.environment}"]
    }
  }
}

resource "aws_iam_role" "nhs_e_cross_account" {
  name               = "nhs-e-cross-account-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "nhs-e-cross-account-role-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

# IAM Policy for Secrets Manager access (read-only)
data "aws_iam_policy_document" "secrets_manager_policy" {
  statement {
    sid    = "GetSecretValue"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:nhs-e/*"
    ]
  }

  statement {
    sid    = "DecryptSecret"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]

    resources = [aws_kms_key.nhs_e_secrets.arn]
  }
}

resource "aws_iam_role_policy" "nhs_e_secrets_policy" {
  name   = "nhs-e-secrets-policy"
  role   = aws_iam_role.nhs_e_cross_account.id
  policy = data.aws_iam_policy_document.secrets_manager_policy.json
}

# Placeholder secrets for IAM policy scoping
resource "aws_secretsmanager_secret" "placeholder" {
  count = var.create_placeholder_secrets ? 3 : 0

  name                    = "nhs-e/placeholder-${count.index + 1}-${var.environment}"
  description             = "Placeholder secret for IAM policy scoping - ${var.environment}"
  kms_key_id              = aws_kms_key.nhs_e_secrets.id
  recovery_window_in_days = 7

  tags = {
    Name        = "nhs-e-placeholder-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

# Placeholder secret versions (not for actual values, only for resource-level policy testing)
resource "aws_secretsmanager_secret_version" "placeholder" {
  count = var.create_placeholder_secrets ? 3 : 0

  secret_id      = aws_secretsmanager_secret.placeholder[count.index].id
  secret_string  = jsonencode({ placeholder = "true", note = "This is a placeholder secret for IAM policy testing only" })
  version_stages = ["AWSCURRENT"]
}
