###############################################################
# GitHub Actions OIDC Provider (existing AWS provider)
###############################################################
data "aws_iam_openid_connect_provider" "github_actions" {
  # Reference the AWS OIDC provider for GitHub Actions
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
}

###############################################################
# IAM Trust Policy — GitHub Actions (Main Branch Only)
###############################################################
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      # Allow authentication only via GitHub's OIDC provider
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
    }

    # Required for GitHub OIDC → AWS IAM role assumption
    actions = ["sts:AssumeRoleWithWebIdentity"]

    # Enforce that ONLY the main branch can assume this role
    # GitHub OIDC token 'sub' claim looks like:
    #   repo:<org>/<repo>:ref:refs/heads/main
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main",
      ]
    }

    # Ensure the token is intended for AWS STS (mandatory for GitHub OIDC)
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

###############################################################
# IAM Role — Deployment Role (Main Branch Only)
###############################################################
resource "aws_iam_role" "github_actions" {
  name = var.role_name
  # Attach the trust policy above
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

###############################################################
# IAM Permissions — Deployment Role (Full Infra Access)
###############################################################
data "aws_iam_policy_document" "deploy_permissions" {

  ###############################################################
  # S3 Bucket + Lifecycle + Encryption Management
  # Required for Terraform-managed infrastructure buckets
  ###############################################################
  statement {
    sid    = "ManageS3BucketsPoliciesEncryptionAndLifecycle"
    effect = "Allow"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketEncryption",
      "s3:GetBucketLifecycleConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:PutBucketEncryption",
      "s3:PutBucketLifecycleConfiguration",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning"
    ]

    # Broad S3 access — required for infra provisioning
    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*",
    ]
  }

  ###############################################################
  # Terraform State (.tfstate) Read/Write
  ###############################################################
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

  ###############################################################
  # Terraform Lock File Management
  ###############################################################
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

  ###############################################################
  # Secrets Manager — Full Secret Lifecycle
  ###############################################################
  statement {
    sid = "ManageSecretsManagerSecretsAndResourcePolicies"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:ListSecrets",
      "secretsmanager:PutResourcePolicy",
      "secretsmanager:PutSecretValue",
      "secretsmanager:RestoreSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:UntagResource",
      "secretsmanager:ValidateResourcePolicy"
    ]
    resources = ["arn:aws:secretsmanager:*:*:secret:*"]
  }

  ###############################################################
  # KMS — Key + Alias + Grant Management
  ###############################################################
  statement {
    sid = "ManageKmsKeysAliasesAndPolicies"
    actions = [
      "kms:CancelKeyDeletion",
      "kms:CreateAlias",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:DisableKey",
      "kms:EnableKey",
      "kms:EnableKeyRotation",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:UpdateAlias",
      "kms:DeleteAlias",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [
      "arn:aws:kms:*:*:key/*",
      "arn:aws:kms:*:*:alias/*"
    ]
  }

  ###############################################################
  # KMS Global Permissions (Key Creation)
  ###############################################################
  statement {
    sid = "KmsGlobalPermissions"
    actions = [
      "kms:CreateKey",
      "kms:ListKeys",
      "kms:ListAliases"
    ]
    resources = ["*"]
  }

  ###############################################################
  # IAM Role + Policy Management
  ###############################################################
  statement {
    sid = "ManageIamRolesAndPolicies"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:ListOpenIDConnectProviders",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::*:policy/*",
      "arn:aws:iam::*:role/*",
    ]
  }

  ###############################################################
  # DynamoDB — Table + Item Management
  ###############################################################
  statement {
    sid    = "DynamoDBTableManagement"
    effect = "Allow"

    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
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

  ###############################################################
  # CloudWatch Logs — Log Group Management
  ###############################################################
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListLogGroups",
    ]

    resources = ["arn:aws:logs:*:*:log-group:*"]
  }
}

###############################################################
# Attach Permissions to Deployment Role
###############################################################
resource "aws_iam_role_policy" "deploy_permissions_policy" {
  name   = "infra-deploy-permissions"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}
