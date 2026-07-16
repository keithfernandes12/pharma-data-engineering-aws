resource "aws_athena_workgroup" "main" {
  name = "${var.project_prefix}-wg"

  configuration {
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.datalake.bucket}/athena-results/"
    }
  }

  force_destroy = true
}
