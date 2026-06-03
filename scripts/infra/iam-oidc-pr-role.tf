data "aws_iam_openid_connect_provider" "github_actions_readonly" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
}

data "aws_iam_policy_document" "github_actions_assume_role_readonly" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions_readonly" {
  name               = var.role_name_readonly
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_readonly.json
}

data "aws_iam_policy_document" "deploy_permissions_readonly" {
  statement {
    sid    = "S3BucketManagement"
    effect = "Allow"

    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketEncryption",
      "s3:PutBucketEncryption",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*",
    ]
  }

  statement {
    sid    = "DynamoDBTableManagement"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:UpdateTable",
      "dynamodb:ListTables",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
    ]
    resources = ["arn:aws:dynamodb:*:*:table/*"]
  }

  statement {
    sid    = "SecretsManagerManagement"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecrets",
    ]

    resources = ["arn:aws:secretsmanager:*:*:secret:*"]
  }

  statement {
    sid    = "KMSKeyManagement"
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:GetKeyPolicy",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["arn:aws:kms:*:*:key/*"]
  }

  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:ListRoles",
      "iam:UpdateAssumeRolePolicy",
      "iam:GetAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
    ]

    resources = ["arn:aws:iam::*:role/*"]
  }

  statement {
    sid    = "IAMPolicyManagement"
    effect = "Allow"

    actions = [
      "iam:GetPolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
    ]

    resources = [
      "arn:aws:iam::*:policy/*",
      "arn:aws:iam::*:role/*",
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:ListTagsLogGroup"
    ]

    resources = ["arn:aws:logs:*:*:log-group:*"]
  }
}

resource "aws_iam_role_policy" "deploy_permissions_readonly" {
  name   = "deploy-permissions-readonly"
  role   = aws_iam_role.github_actions_readonly.id
  policy = data.aws_iam_policy_document.deploy_permissions_readonly.json
}
