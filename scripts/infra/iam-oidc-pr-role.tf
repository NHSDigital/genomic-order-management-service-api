data "aws_iam_openid_connect_provider" "github_actions_pr" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
}

data "aws_iam_policy_document" "github_actions_assume_role_pr" {
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

resource "aws_iam_role" "github_actions_pr" {
  name               = var.role_name_pr
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_pr.json
}

data "aws_iam_policy_document" "deploy_permissions_pr" {
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
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*",
    ]
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

resource "aws_iam_role_policy" "deploy_permissions_pr" {
  name   = "deploy-permissions-pr"
  role   = aws_iam_role.github_actions_pr.id
  policy = data.aws_iam_policy_document.deploy_permissions_pr.json
}
