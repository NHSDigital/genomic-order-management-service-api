locals {

  common_tags = merge(
    {
      ManagedBy = "Terraform"
      Purpose   = "GitHub OIDC bootstrap"
    },
    var.tags
  )

}