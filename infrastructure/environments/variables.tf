# Shared variables for all environments
variable "project" {
  description = "Project name used for tagging and resource naming."
  type        = string
  default     = "genomics"
}

variable "region" {
  description = "AWS region for infrastructure deployment."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name (int, prod)."
  type        = string
}

variable "irs_role_arn" {
  description = "ARN of the InterSystems IAM role that will assume the NHS-E cross-account role."
  type        = string
}

variable "create_placeholder_secrets" {
  description = "Whether to create placeholder secrets in AWS Secrets Manager for IAM policy scoping."
  type        = bool
  default     = true
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic rotation of the KMS CMK."
  type        = bool
  default     = true
}
