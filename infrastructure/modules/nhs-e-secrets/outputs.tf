# Module outputs
output "kms_key_id" {
  description = "KMS key ID for the NHS-E secrets"
  value       = aws_kms_key.nhs_e_secrets.id
}

output "kms_key_arn" {
  description = "KMS key ARN for the NHS-E secrets"
  value       = aws_kms_key.nhs_e_secrets.arn
}

output "kms_key_alias" {
  description = "KMS key alias for the NHS-E secrets"
  value       = aws_kms_alias.nhs_e_secrets.name
}

output "nhs_e_role_arn" {
  description = "ARN of the NHS-E cross-account IAM role"
  value       = aws_iam_role.nhs_e_cross_account.arn
}

output "nhs_e_role_name" {
  description = "Name of the NHS-E cross-account IAM role"
  value       = aws_iam_role.nhs_e_cross_account.name
}

output "placeholder_secret_arns" {
  description = "ARNs of the placeholder secrets created for IAM policy scoping"
  value       = var.create_placeholder_secrets ? aws_secretsmanager_secret.placeholder[*].arn : []
}

output "placeholder_secret_names" {
  description = "Names of the placeholder secrets created for IAM policy scoping"
  value       = var.create_placeholder_secrets ? aws_secretsmanager_secret.placeholder[*].name : []
}
