# Data lake bucket — the project's storage layer.
#
# One bucket holds both zones via key prefixes:
#   raw/        verbatim source CSVs (landing zone)
#   processed/  cleaned Parquet written by the Glue ETL (curated zone)
# (S3 has no real folders; a "zone" is just a key prefix that appears when
#  objects are uploaded under it.)

# Look up the current account ID so the bucket name is globally unique without
# hardcoding it. S3 bucket names must be unique across ALL AWS accounts on Earth.
data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.project_prefix}-datalake-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "datalake" {
  bucket = local.bucket_name
}

# Security: block ALL forms of public access. This is the single most important
# S3 safety control — accidental public buckets are a top cause of data leaks.
resource "aws_s3_bucket_public_access_block" "datalake" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Keep prior versions of objects if overwritten — cheap insurance for a data lake.
resource "aws_s3_bucket_versioning" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  versioning_configuration {
    status = "Enabled"
  }
}
