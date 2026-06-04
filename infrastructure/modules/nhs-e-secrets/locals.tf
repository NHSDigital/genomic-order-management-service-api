locals {

  common_tags = merge(
    {
      ManagedBy = "Terraform"
      module    = "NHS-E Secrets"
    },
    var.tags
  )
}
