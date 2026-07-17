resource "aws_s3_object" "spark_script" {
  bucket = aws_s3_bucket.datalake.id
  key    = "scripts/build_fact_drug_approvals_spark.py"
  source = "${path.module}/../glue/build_fact_drug_approvals_spark.py"
  etag   = filemd5("${path.module}/../glue/build_fact_drug_approvals_spark.py")
}

resource "aws_glue_job" "approvals_spark" {
  name         = "${var.project_prefix}-approvals-spark"
  role_arn     = aws_iam_role.glue_crawler.arn
  glue_version = "4.0"
  worker_type  = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.datalake.bucket}/scripts/build_fact_drug_approvals_spark.py"
    python_version  = "3"
  }

  default_arguments = {
    "--bucket"                           = aws_s3_bucket.datalake.bucket
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://${aws_s3_bucket.datalake.bucket}/glue-temp/"
    "--enable-job-insights"              = "false"
    "--job-bookmark-option"              = "job-bookmark-disable"
  }

  max_retries = 0
  timeout     = 10
}
