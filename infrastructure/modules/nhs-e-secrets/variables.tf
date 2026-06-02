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
