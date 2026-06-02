# Production environment configuration
module "nhs_e_secrets" {
  source = "../../modules/nhs-e-secrets"

  project                 = var.project
  region                  = var.region
  environment             = var.environment
  irs_role_arn            = var.irs_role_arn
  enable_kms_key_rotation = var.enable_kms_key_rotation
}
