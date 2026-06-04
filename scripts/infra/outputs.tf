output "terraform_state_bucket_name" {
  value = aws_s3_bucket.terraform_state_store.bucket
}


output "github_actions_role_name" {
  value = aws_iam_role.github_actions.name
}

output "github_actions_pr_role_name" {
  value = aws_iam_role.github_actions_pr.name
}
