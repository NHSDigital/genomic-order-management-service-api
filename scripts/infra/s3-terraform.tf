locals {
  terraform_state_bucket_name = "${var.project}-tfstate-${var.environment}"
}

resource "aws_s3_bucket" "terraform_state_store" {
  bucket = local.terraform_state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    project     = var.project
    Name        = "${local.terraform_state_bucket_name}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_store" {
  bucket = aws_s3_bucket.terraform_state_store.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform_state_ownership" {
  bucket = aws_s3_bucket.terraform_state_store.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_acl" "terraform-state-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform_state_ownership]

  bucket = aws_s3_bucket.terraform_state_store.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_store" {
  bucket = aws_s3_bucket.terraform_state_store.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_store" {
  bucket = aws_s3_bucket.terraform_state_store.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
