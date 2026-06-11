# Infrastructure

This folder contains the Terraform-based infrastructure assets for the genomic-order-management-service-api project.

## Contents

- `environments/` – environment-specific Terraform configurations for `int` and `prod`.
  - Shared variables are defined in `environments/terraform.tfvars`.
  - Each environment folder contains its own `main.tf` entry point.
- `modules/` – reusable Terraform modules.
  - `nhs-e-secrets/` provisions AWS Secrets Manager resources and related IAM/KMS configuration.
- `images/` – placeholder area for infrastructure-related images or diagrams.

## Current setup

The current Terraform configuration uses the `nhs-e-secrets` module to create environment-specific secret resources and related access controls.

### What the `nhs-e-secrets` module deploys

The `infrastructure/modules/nhs-e-secrets` module provisions:

- one or more AWS Secrets Manager secrets for the selected environment
- placeholder secret values (managed by the NHS-E service team, not real application secrets)
- an AWS KMS key and alias for encrypting those secrets
- an IAM role and policy that allow an external InterSystems role to read the secrets using the KMS key

This module is intended to create the secret placeholder infrastructure and the required cross-account access path, rather than manage live secret contents.

## Typical workflow

Terraform for this folder is not run manually in the normal development flow.

Instead, GitHub Actions handles the infrastructure lifecycle as follows:

- Pull request and merge validation runs through `.github/workflows/infra-validate.yaml`, which is invoked from `.github/workflows/cicd-1-pull-request.yaml` for the configured environments. This validates the Terraform changes but does not deploy them.
- Deployment runs through `.github/workflows/infra-deploy.yaml`, which is invoked from `.github/workflows/cicd-3-deploy.yaml` when the deploy workflow is started manually. This is the path that performs the Terraform init, plan, and apply steps for the selected environment under `infrastructure/environments/`.

In other words, a merged PR triggers validation, while actual infrastructure deployment is manual through the deploy workflow.

## Notes

- Environment variables and shared defaults are defined in `infrastructure/environments/terraform.tfvars`.
- The `prod` configuration currently includes a placeholder IAM role value for testing purposes.
