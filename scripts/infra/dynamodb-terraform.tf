resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.project}-tfstate-lock-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    project     = var.project
    Name        = "terraform-lock-${var.environment}"
    Environment = var.environment
  }
}
