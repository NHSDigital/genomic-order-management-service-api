
data "aws_iam_policy_document" "secrets_manager_kms_key" {
  statement {
    sid     = "AllowAccountIamAdministration"
    effect  = "Allow"
    actions = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid    = "AllowGitHubRoleUseOfSecretsManagerKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.nhs_e_secretsreader_role.arn]
    }

    resources = ["*"]
  }

  statement {
    sid    = "AllowSecretReaderRoleUseOfSecretsManagerKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.nhs_e_secretsreader_role.arn]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.region}.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowSecretsManagerServiceUse"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo"
    ]

    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "secrets_manager" {
  description         = "KMS key for Secrets Manager"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.secrets_manager_kms_key.json
  tags                = merge(local.common_tags, { Name = "${var.project}" })
}

resource "aws_kms_alias" "secrets_manager" {
  name          = "alias/${var.project}-key"
  target_key_id = aws_kms_key.secrets_manager.key_id
}
