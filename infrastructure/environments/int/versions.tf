terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "genomics-order-management-tfstate-int"
    key            = "nhs-e/infrastructure/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "genomic-order-management-service-api-tfstate-lock-prod"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }
}
