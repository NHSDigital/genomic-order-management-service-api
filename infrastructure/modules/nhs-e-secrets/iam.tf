# IAM Role for NHS-E cross-account access
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.intersystems_role_arn]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["{var.external_id}"]
    }
  }
}

resource "aws_iam_role" "nhs_e_cross_account" {
  name               = "{var.Project}-is-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "{var.Project}-is-${var.environment}"
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
