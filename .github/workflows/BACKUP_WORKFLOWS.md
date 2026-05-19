# GitHub Actions Workflows - Backup & Documentation

## Existing Workflows (Before Infrastructure-as-Code Addition)

This document backs up the configuration of existing workflows before new infrastructure-as-code pipelines are added.

### Existing Workflows
1. **cicd-1-pull-request.yaml** - Runs on PR: metadata, commit, test, build, acceptance stages
2. **cicd-3-deploy.yaml** - Manual deployment workflow with tag input
3. **stage-1-commit.yaml** - Scan secrets, check formats, lint Terraform
4. **stage-2-test.yaml** - Test stage
5. **stage-3-build.yaml** - Build stage
6. **stage-4-acceptance.yaml** - Acceptance tests

### New Workflows Added (Infrastructure-as-Code)
1. **infra-validate.yaml** - Feature branch validation: PR checks including terraform plan for infrastructure/
2. **infra-deploy.yaml** - Post-merge deployment: Manual dispatch with environment selection (int/prod)

### Workflow Changes
- Existing workflows remain unchanged
- New workflows are independent and do not interfere with existing CI/CD
- Terraform infrastructure deployment uses the same commit-stage checks (secrets scan, format validation, terraform lint)
- Infrastructure deployment uses existing AWS credentials via GitHub OIDC

### Key Design Points
- Branch-based: Feature branches can only validate, not deploy
- Manual dispatch: Deployment happens after merge via workflow_dispatch with environment selection
- Approval gates: Branch protection + environment protection rules ensure safety
- Credential management: Uses GitHub OIDC role from scripts/infra (github-genomics-oidc-role)

