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
}

variable "external_id" {
  description = "external_id passed by InterSystems"
  type        = string
}
