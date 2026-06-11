# Infrastructure Bootstrap (`scripts/infra`)

## Overview

The scripts/infra directory contains the one‑time bootstrap Terraform configuration required to provision the foundational AWS infrastructure used by the genomic-order-management-service-api Terraform deployments.
This bootstrap layer creates:
- The Terraform remote state backend (S3 + versioning + encryption + access controls)
- The GitHub Actions OIDC IAM roles used for:
	- Production deployments (full‑privilege deploy role)
	- Pull request / read‑only operations (restricted role)
- The OIDC trust relationships that allow GitHub Actions to authenticate without long‑lived AWS credentials
This directory is only used during initial setup or importing existing resources into Terraform state.

---

## What This Bootstrap Creates

### Terraform State Backend (S3)

Terraform state is stored in a dedicated S3 bucket: genomics-order-management-tfstate-prod

The bucket is configured with:

- Versioning enabled
- Server‑side encryption (AES‑256)
- Public access fully blocked
- Bucket ownership controls
- `prevent_destroy` lifecycle rule

Defined in:

- `s3-terraform.tf`
- `variables.tf`

---

### GitHub Actions OIDC IAM Roles

Two IAM roles are created to support CI/CD workflows.

---

#### 1. Deployment Role
**`github-genomics-order-management-oidc-deploy-role`**

Used by GitHub Actions for ***main‑branch deployments.
Capabilities include:
- Managing S3 buckets and Terraform state
- Managing Secrets Manager secrets
- Managing KMS keys and aliases
- Managing IAM roles and policies
- Managing DynamoDB tables
- Managing CloudWatch log groups
The trust policy restricts role assumption to:
- The configured GitHub organisation and repository
- The main branch only
- GitHub’s OIDC provider (token.actions.githubusercontent.com)
(Additional branch enforcement is implemented in the GitHub Actions workflow.)

---

#### 2. Pull Request / Read‑Only Role
**`github-genomics-order-management-oidc-pr-role`**

Used for PR workflows that require:

- Reading Terraform state
- Reading Secrets Manager
- Reading IAM roles/policies
- Reading CloudWatch logs

This role **cannot modify infrastructure**.

---
OIDC Identity Provider
Both IAM roles reference the existing AWS OIDC provider for GitHub Actions:
data "aws_iam_openid_connect_provider" "github_actions" { ... }
This enables GitHub Actions to authenticate securely without long‑lived AWS credentials.

---
Example: `genomics-order-management-tfstate-prod`

The bucket is configured with:

- Versioning enabled
- Server‑side encryption (AES‑256)
- Public access fully blocked
- Bucket ownership controls
- `prevent_destroy` lifecycle rule

Defined in:

- `s3-terraform.tf`
- `variables.tf`


---

### Usage
***one time Initial Setup
```
cd scripts/infra

terraform init

terraform plan \
  -var github_org=NHSDigital \
  -var github_repo=genomic-order-management-service-api

terraform apply
```

***Importing Existing Resources
If the S3 bucket or IAM roles already exist (e.g., created manually or by a previous bootstrap), use the provided import script:
cd scripts/infra
./tf_import.sh

---
Summary
This directory provides the foundational AWS infrastructure required for secure, GitHub‑based Terraform deployments:
- S3 backend for Terraform state
- Two IAM roles (deploy + PR) with OIDC trust
- Import script for existing resources
- Fully parameterised Terraform configuration
It is only used during bootstrap or resource import, not during normal application deployments.

