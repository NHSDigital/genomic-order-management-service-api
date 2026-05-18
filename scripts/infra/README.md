# scripts/infra README

## Purpose

The `scripts/infra` directory contains **one-time bootstrap Terraform configuration** for setting up the foundational AWS infrastructure required to manage the genomic-order-management-service-api application infrastructure using Terraform.

## What This Sets Up

This directory creates the infrastructure **backend** and **deployment prerequisites**:

1. **Terraform State Backend (S3 + DynamoDB)**
   - S3 bucket for storing Terraform state files (`s3-terraform.tf`)
   - DynamoDB table for state locking (`dynamodb-terraform.tf`)
   - Enables safe, concurrent Terraform operations

2. **GitHub Actions OIDC Integration**
   - AWS IAM role for GitHub Actions (`iam-oidc.tf`)
   - Trust policy allowing GitHub Actions workflows to assume the role
   - Granular permissions for Terraform deployments
   - No long-lived credentials stored in pipeline

3. **OIDC Identity Provider**
   - Existing AWS OIDC provider for GitHub Actions (referenced via data source)
   - Used by the IAM role for secure authentication

## Usage

### Initial Setup (One-Time)

```bash
# Navigate to scripts/infra
cd scripts/infra

# Initialize Terraform with local backend
terraform init

# Review the plan
terraform plan -var github_org=NHSDigital -var github_repo=genomic-order-management-service-api

# Apply the infrastructure
terraform apply
```

### Configuration

Environment variables and defaults:
1. aws_region  - eu-west-2 (default)
2. environment - prod (default)
3. github_org - NHSDigital (default)
4. github_repo - genomic-order-management-service-api (default)
5. github_branch - main (default)
6. role_name - github-genomics-oidc-role (default)
7. project - genomics (default)

Override defaults via `-var` flags or `terraform.tfvars` file.

### State Management

- **State Storage**: S3 bucket created and managed by this configuration
- **State Locking**: DynamoDB table prevents concurrent modifications
- **Initial Backend**: Uses local Terraform state initially
- **After Apply**: Configure remote backend in subsequent deployments

### Outputs

After applying, the following outputs are available:

- `role_arn` - GitHub Actions IAM role ARN
- `oidc_provider_arn` - OIDC provider ARN
- `role_name` - GitHub Actions IAM role name
- `github_org` - GitHub organization configured
- `github_repo` - GitHub repository configured
- `github_branch` - GitHub branch allowed for deployments

## Important Notes

**This is a one-time bootstrap setup**
Do NOT re-apply this configuration unless you need to update it
Do NOT delete resources unless you understand the impact on existing deployments
The IAM role and S3/DynamoDB resources are critical for all infrastructure management

**Used by**
All infrastructure deployments in `infrastructure/` directory
GitHub Actions workflows for managing application infrastructure
Terraform state backend for tracking resource state

## Related Documentation

**Infrastructure Deployments**: See `infrastructure/` directory for NHS-E application infrastructure
**GitHub Workflows**: See `.github/workflows/infra-*.yaml` for deployment automation
**IAM Permissions**: Review `iam-oidc.tf` for GitHub Actions role permissions

## Files in This Directory

- `provider.tf` - AWS provider configuration with default tags
- `variables.tf` - Shared variable definitions
- `iam-oidc.tf` - GitHub Actions IAM role and trust policy
- `s3-terraform.tf` - Terraform state S3 bucket
- `dynamodb-terraform.tf` - State locking DynamoDB table
- `outputs.tf` - Infrastructure outputs
- `iam-oidc.sh` - Legacy shell script (for reference/manual setup)
