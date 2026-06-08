# Environment variables for prod
environment = "int"
#NOTE : the below is a dummy external_id used for keeping code ready
external_id = "ext-9f83hf83hf83hf83"

# InterSystems role ARN - this should be provided via terraform.tfvars override or command line
intersystems_role_arn = "arn:aws:iam::038462762332:role/InterSystems-GOM-Role"

tags = {
  Environment        = "int"
  Project            = "genomics-order-management"
  ManagedBy          = "Terraform"
  Owner              = "John Fraser"
  DeliveryLead       = "Cairns-Hockey, Beryl"
  TechnicalArchitect = "Ravi Natarajan"
  BusinessAnalyst    = "Adam Laurent​"
}

secrets = {
  "DGTS-INT" = {
    description             = "Digital Genomic Test Service INT"
    recovery_window_in_days = 7
    secret_key              = "dgts_int"
    tags = {
      environment = "int"
      owner       = "NHS-E Service Team"
    }
  }

  "MNS-INT" = {
    description             = "Multicast Notification Service INT"
    recovery_window_in_days = 7
    secret_key              = "mns_int"
    tags = {
      environment = "int"
      owner       = "NHS-E Service Team"
    }
  }

  "PDM-INT" = {
    description             = "Patient Data Manager INT"
    recovery_window_in_days = 7
    secret_key              = "pdm_int"
    tags = {
      environment = "int"
      owner       = "NHS-E Service Team"
    }
  }

  "ODS-INT" = {
    description             = "Organization Data Service INT"
    recovery_window_in_days = 7
    secret_key              = "ods_int"
    tags = {
      environment = "int"
      owner       = "NHS-E Service Team"
    }
  }

  "PDS-INT" = {
    description             = "Personal Demographic Service INT"
    recovery_window_in_days = 7
    secret_key              = "pds_int"
    tags = {
      environment = "int"
      owner       = "NHS-E Service Team"
    }
  }

  "GOMS-INT" = {
    description             = "Genomic Order Management Service INT"
    recovery_window_in_days = 7
    secret_key              = "goms_int"
    tags = {
      environment = "int"
      owner       = "NHS-E Service Team"
    }
  }
}
