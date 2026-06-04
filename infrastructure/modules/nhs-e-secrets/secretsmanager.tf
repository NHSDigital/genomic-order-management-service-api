
resource "aws_secretsmanager_secret" "nhs_e_secrets" {
  for_each = var.secrets
  name                    = each.value.secret_key
  description             = try(each.value.description, null)
  kms_key_id              = aws_kms_key.secrets_manager.arn
  recovery_window_in_days = try(each.value.recovery_window_in_days, 30)
  tags = merge(local.common_tags, try(each.value.tags, {}))
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_secretsmanager_secret_version" "nhs_e_secrets_version" {
  for_each = var.secrets
  secret_id     = aws_secretsmanager_secret.nhs_e_secrets[each.key].id
  secret_string = jsonencode({ (each.value.secret_key) = "managed-by-nhs-e" })
  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "aws_iam_policy_document" "nhs_e_secrets_access" {
  for_each = var.secrets
  statement {
    sid    = "AllowReaderRole"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.nhs_e_secretsreader_role.name]
    }
    resources = [
      aws_secretsmanager_secret.nhs_e_secrets[each.key].arn
    ]
  }
}

resource "aws_secretsmanager_secret_policy" "nhs_e_secretsmanager_policy" {
  for_each = data.aws_iam_policy_document.nhs_e_secrets_access
  secret_arn = aws_secretsmanager_secret.nhs_e_secrets[each.key].arn
  policy     = each.value.json
  lifecycle {
    ignore_changes = all
  }
}
