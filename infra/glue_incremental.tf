resource "aws_s3_object" "incremental_script" {
  bucket = aws_s3_bucket.datalake.id
  key    = "scripts/incremental_ingest_approvals.py"
  source = "${path.module}/../glue/incremental_ingest_approvals.py"
  etag   = filemd5("${path.module}/../glue/incremental_ingest_approvals.py")
}

resource "aws_glue_job" "incremental_ingest" {
  name              = "${var.project_prefix}-incremental-ingest"
  role_arn          = aws_iam_role.glue_crawler.arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.datalake.bucket}/scripts/incremental_ingest_approvals.py"
    python_version  = "3"
  }

  default_arguments = {
    "--bucket"              = aws_s3_bucket.datalake.bucket
    "--job-language"        = "python"
    "--datalake-formats"    = "iceberg"
    "--TempDir"             = "s3://${aws_s3_bucket.datalake.bucket}/glue-temp/"
    "--job-bookmark-option" = "job-bookmark-disable"
  }

  max_retries = 0
  timeout     = 15
}
