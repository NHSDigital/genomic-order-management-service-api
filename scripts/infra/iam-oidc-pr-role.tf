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
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_state_store.arn
    ]
  }

  statement {
    sid    = "ReadWriteTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state_store.arn}/*.tfstate"
    ]
  }

  statement {
    sid    = "ReadWriteDeleteTerraformLockFile"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.terraform_state_store.arn}/*.tfstate.tflock"
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
      "kms:GenerateDataKey"
    ]

    resources = ["arn:aws:kms:*:*:key/*"]
  }

  statement {
    sid    = "ReadIAMRoleAndPolicies"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRoles",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:GetAssumeRolePolicy"
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
      "iam:GetPolicyVersion"
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
