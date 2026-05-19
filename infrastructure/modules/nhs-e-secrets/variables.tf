# Module variables
variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (int, prod)"
  type        = string
}

variable "irs_role_arn" {
  description = "ARN of the InterSystems IAM role that will assume this NHS-E role"
  type        = string
}

variable "create_placeholder_secrets" {
  description = "Whether to create placeholder secrets"
  type        = bool
  default     = true
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic rotation of the KMS key"
  type        = bool
  default     = true
}
