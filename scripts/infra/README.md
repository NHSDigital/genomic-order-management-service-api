## scripts/infra README

### Purpose

The `scripts/infra` directory contains **one-time bootstrap Terraform configuration** for setting up the foundational AWS infrastructure required to manage the `genomic-order-management-service-api` application infrastructure using Terraform.

---

### What This Sets Up

This directory creates the infrastructure **backend** and **deployment prerequisites**:

- **Terraform State Backend (S3 + DynamoDB)**
  - S3 bucket for storing Terraform state files (`s3-terraform.tf`)
  - DynamoDB table for state locking (`dynamodb-terraform.tf`)
  - Enables safe, concurrent Terraform operations

- **GitHub Actions OIDC Integration**
  - AWS IAM role for GitHub Actions (`iam-oidc.tf`)
  - Trust policy allowing GitHub Actions workflows to assume the role
  - Granular permissions for Terraform deployments
  - No long-lived credentials stored in the pipeline

- **OIDC Identity Provider**
  - Existing AWS OIDC provider for GitHub Actions (referenced via data source)
  - Used by the IAM role for secure authentication

---

### Usage

#### Initial Setup (One-Time)

```bash
# Navigate to scripts/infra
cd scripts/infra

# Initialize Terraform with local backend
terraform init

# Review the plan
terraform plan \
  -var github_org=NHSDigital \
  -var github_repo=genomic-order-management-service-api

# Apply the infrastructure
terraform apply