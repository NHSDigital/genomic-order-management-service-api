# Production environment configuration
module "nhs_e_secrets" {
  source = "../../modules/nhs-e-secrets"

  project               = var.project
  region                = var.region
  environment           = var.environment
  intersystems_role_arn = var.intersystems_role_arn
  external_id           = var.external_id
  tags                  = var.tags
  secrets               = var.secrets
}
