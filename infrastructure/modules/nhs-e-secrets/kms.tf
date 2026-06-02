resource "aws_kms_alias" "nhs_e_secrets" {
  name          = "alias/nhs-e-secrets-${var.environment}"
  target_key_id = aws_kms_key.nhs_e_secrets.key_id
}

# KMS Customer Managed Key for encrypting secrets
resource "aws_kms_key" "nhs_e_secrets" {
  description             = "KMS key for NHS-E secrets encryption - ${var.environment}"
  enable_key_rotation     = true

  tags = {
    Name        = "nhs-e-secrets-key-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}
