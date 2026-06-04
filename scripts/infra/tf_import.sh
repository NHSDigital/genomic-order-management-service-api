#!/usr/bin/env bash

AWS_REGION="eu-west-2"
PROJECT="genomics-order-management"
ENVIRONMENT="prod"

ROLE_NAME="github-genomics-order-management-oidc-deploy-role"
ROLE_NAME_READONLY="github-genomics-order-management-oidc-pr-role"

BUCKET="${PROJECT}-tfstate-${ENVIRONMENT}"
TABLE="${PROJECT}-tfstate-lock-${ENVIRONMENT}"

terraform init -input=false

import_if_needed() {
  local addr=$1
  local id=$2

  if terraform state list 2>/dev/null | grep -q "^${addr}$"; then
    echo "✔ Already imported: $addr"
    return
  fi

  echo "→ Importing $addr with ID: $id"

  if ! terraform import "$addr" "$id"; then
    echo " FAILED: $addr"
    echo "   ID used: $id"
    exit 1
  fi
}


import_if_needed aws_s3_bucket.terraform_state_store "$BUCKET"
import_if_needed aws_s3_bucket_versioning.terraform_state_store "$BUCKET"
import_if_needed aws_s3_bucket_acl.terraform-state-acl "$BUCKET"
import_if_needed aws_s3_bucket_server_side_encryption_configuration.terraform_state_store "$BUCKET"
import_if_needed aws_s3_bucket_public_access_block.terraform_state_store "$BUCKET"
import_if_needed aws_s3_bucket_ownership_controls.terraform_state_ownership "$BUCKET"

import_if_needed aws_dynamodb_table.terraform_state_lock "$TABLE"

import_if_needed aws_iam_role.github_actions "$ROLE_NAME"
import_if_needed aws_iam_role.github_actions_pr "$ROLE_NAME_READONLY"


terraform state list

terraform plan -input=false

echo "Import completed successfully"