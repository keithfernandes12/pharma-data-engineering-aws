locals {
  bucket_name = "${var.project_prefix}-datalake-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "datalake" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "datalake" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  versioning_configuration {
    status = "Enabled"
  }
}
