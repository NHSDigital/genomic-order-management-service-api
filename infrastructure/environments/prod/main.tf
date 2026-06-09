# Production environment configuration
#  intersystems_role_arn = var.intersystems_role_arn
# the below must be replaced by InterSystems Role, added for testing
data "aws_caller_identity" "current" {}

module "nhs_e_secrets" {
  source                = "../../modules/nhs-e-secrets"
  project               = var.project
  region                = var.region
  environment           = var.environment
  intersystems_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  external_id           = var.external_id
  tags                  = var.tags
  secrets               = var.secrets
}
