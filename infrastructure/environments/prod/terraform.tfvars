# Environment variables for prod
environment = "prod"
#NOTE : the below is a dummy external_id used for keeping code ready
external_id = "ext-9f83hf83hf83hf83"

# InterSystems role ARN - this should be provided via terraform.tfvars override or command line
# Example: intersystems_role_arn = "arn:aws:iam::038462762332:role/InterSystems-GOM-Role"

tags = {
  Environment        = "prod"
  Project            = "genomics-order-management"
  ManagedBy          = "Terraform"
  Owner              = "John Fraser"
  DeliveryLead       = "Cairns-Hockey, Beryl"
  TechnicalArchitect = "Ravi Natarajan"
  BusinessAnalyst    = "Harini Nallapothola​"
}