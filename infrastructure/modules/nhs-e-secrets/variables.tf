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

variable "intersystems_role_arn" {
  description = "ARN of the InterSystems IAM role that will assume this NHS-E role"
  type        = string
}

variable "external_id" {
  description = "external_id passed by InterSystems"
  type        = string
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

variable "tags" {
  description = "Tags applied to resources that support tagging."
  type        = map(string)
  default     = {}
}