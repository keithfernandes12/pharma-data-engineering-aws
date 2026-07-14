# Outputs — values Terraform prints after apply and that other tooling/milestones
# can consume (e.g. `terraform output -raw datalake_bucket_name`).

output "datalake_bucket_name" {
  description = "Name of the S3 data lake bucket."
  value       = aws_s3_bucket.datalake.bucket
}

output "datalake_bucket_arn" {
  description = "ARN of the S3 data lake bucket."
  value       = aws_s3_bucket.datalake.arn
}

output "raw_prefix_uri" {
  description = "S3 URI of the raw (landing) zone."
  value       = "s3://${aws_s3_bucket.datalake.bucket}/raw/"
}

output "processed_prefix_uri" {
  description = "S3 URI of the processed (curated) zone."
  value       = "s3://${aws_s3_bucket.datalake.bucket}/processed/"
}
