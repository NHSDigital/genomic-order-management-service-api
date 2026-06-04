data "aws_iam_policy_document" "nhs_e_secretsreader_trust_policy" {

  statement {
    sid     = "AllowAccountBRolesAssumeSecretReader"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.intersystems_role_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "nhs_e_secretsreader_role" {
  name               = "${var.project}-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.nhs_e_secretsreader_trust_policy.json
  #  max_session_duration = var.max_session_duration
  #    permissions_boundary = var.permissions_boundary_arn

  tags = merge(local.common_tags, { Purpose = "Cross-account Secrets Manager reader" })
}

data "aws_iam_policy_document" "nhs_e_secretsreader_role_policy_document" {

  statement {
    sid    = "ReadManagedSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [for secret in aws_secretsmanager_secret.nhs_e_secrets : secret.arn]
  }

  statement {
    sid    = "DecryptSecretsManagerKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.secrets_manager.arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "nhs_e_secretsreader_role_policy" {
  name        = "${var.project}-${var.environment}-role-policy"
  description = "Allows reading Secrets Manager secrets"
  policy      = data.aws_iam_policy_document.nhs_e_secretsreader_role_policy_document.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "nhs_e_secretsreader_role_policy_attachment" {
  role       = aws_iam_role.nhs_e_secretsreader_role.name
  policy_arn = aws_iam_policy.nhs_e_secretsreader_role_policy.arn
}