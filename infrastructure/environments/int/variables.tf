# Shared variables for all environments
variable "project" {
  description = "Project name used for tagging."
  type        = string
  default     = "genomics-order-management"
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

variable "intersystems_role_arn" {
  description = "ARN of the InterSystems IAM role that will assume the NHS-E cross-account role."
  type        = string
  default     = ""
}

variable "external_id" {
  description = "external_id passed by InterSystems"
  type        = string
}

variable "enable_kms_key_rotation" {
  description = "Enable KMS key rotation for secrets manager."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to resources that support tagging."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets Manager secrets to create. NOTE: THIS IS ONLY TO CREATE SECRET PLACEHOLDERS AND NO REAL SECRETS. Secrets are managed by NHS-E service team"
  type = map(object({
    description             = optional(string)
    recovery_window_in_days = optional(number, 30)
    secret_key              = optional(string)
    tags                    = optional(map(string), {})
  }))
  default = {}
}

