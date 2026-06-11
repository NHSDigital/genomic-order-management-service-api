###############################################
# GitHub Actions OIDC Trust Policy (PR Role)
###############################################
data "aws_iam_policy_document" "github_actions_assume_role_pr" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      # Trust the GitHub Actions OIDC provider for authentication
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
    }

    # Required for GitHub OIDC → AWS IAM role assumption
    actions = ["sts:AssumeRoleWithWebIdentity"]

    # Restrict which GitHub workflow identities may assume this role
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      # Allow any branch (refs/heads/*) but only for this repo
      # Example: repo:NHSDigital/genomic-order-management-service-api:ref:refs/heads/feature/foo
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/*",
      ]
    }

    # GitHub OIDC tokens always set audience = sts.amazonaws.com
    # This ensures the token is intended for AWS STS and not another service
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

###############################################
# IAM Role for PR Workflows (Read‑Only)
###############################################
resource "aws_iam_role" "github_actions_pr" {
  name = var.role_name_pr
  # Attach the trust policy defined above
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_pr.json
}

###############################################
# Permissions for PR Role (Read‑Only Terraform)
###############################################
data "aws_iam_policy_document" "deploy_permissions_pr" {

  ###############################################
  # Allow listing the Terraform state bucket
  # Required for terraform init/plan in PR workflows
  ###############################################
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

  ###############################################
  # Allow reading/writing .tfstate files
  # PR workflows may run terraform plan which writes a local state
  ###############################################
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

  ###############################################
  # Allow reading/writing/deleting Terraform lock files
  # Required for terraform init/plan concurrency control
  ###############################################
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

  ###############################################
  # Allow reading secrets (but not modifying them)
  # Needed for terraform plan when modules reference secrets
  ###############################################
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

  ###############################################
  # Allow read‑only access to KMS keys
  # Required for decrypting encrypted Terraform state or secrets
  ###############################################
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

  ###############################################
  # Allow reading IAM roles/policies
  # Required when Terraform references IAM resources in data sources
  ###############################################
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

  ###############################################
  # Allow reading IAM policies
  # Required for terraform plan when IAM policies are referenced
  ###############################################
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

  ###############################################
  # Allow read‑only access to CloudWatch Logs
  # Useful for debugging PR workflows or module behaviour
  ###############################################
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

###############################################
# Attach the read‑only policy to the PR role
###############################################
resource "aws_iam_role_policy" "deploy_permissions_pr" {
  name   = "deploy-permissions-pr"
  role   = aws_iam_role.github_actions_pr.id
  policy = data.aws_iam_policy_document.deploy_permissions_pr.json
}
