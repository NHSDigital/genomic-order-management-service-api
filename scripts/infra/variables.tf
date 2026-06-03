variable "aws_region" {
  description = "AWS region where the IAM resources are created."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project name used for tagging."
  type        = string
  default     = "genomics-order-management"
}

variable "github_org" {
  description = "GitHub organization owning the repository."
  type        = string
  default     = "NHSDigital"
}

variable "github_repo" {
  description = "GitHub repository name for the OIDC trust relationship."
  type        = string
  default     = "genomic-order-management-service-api"
}

variable "github_branch" {
  description = "GitHub branch allowed for OIDC trust relationship."
  type        = string
  default     = "main"
}

variable "role_name" {
  description = "Name of the IAM role created for GitHub Actions."
  type        = string
  default     = "github-genomics-order-management-oidc-deploy-role"
}

variable "role_name_readonly" {
  description = "Name of the IAM role created for GitHub Actions."
  type        = string
  default     = "github-genomics-order-management-oidc-pr-role"
}

variable "oidc_provider" {
  description = "OIDC provider host for GitHub Actions."
  type        = string
  default     = "token.actions.githubusercontent.com"
}
