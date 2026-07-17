data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn" {
  name               = "${var.project_prefix}-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json
}

data "aws_iam_policy_document" "sfn_permissions" {
  statement {
    sid       = "Crawler"
    actions   = ["glue:StartCrawler", "glue:GetCrawler"]
    resources = ["*"]
  }
  statement {
    sid = "GlueJob"
    actions = [
      "glue:StartJobRun",
      "glue:GetJobRun",
      "glue:GetJobRuns",
      "glue:BatchStopJobRun",
    ]
    resources = ["*"]
  }
  statement {
    sid = "SyncCallbacks"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule",
    ]
    resources = ["arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForGlueJobRule"]
  }
}

resource "aws_iam_role_policy" "sfn" {
  name   = "${var.project_prefix}-sfn-permissions"
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn_permissions.json
}

resource "aws_sfn_state_machine" "pipeline" {
  name     = "${var.project_prefix}-pipeline"
  role_arn = aws_iam_role.sfn.arn

  definition = jsonencode({
    Comment = "Pharma pipeline: crawl raw -> (poll until READY) -> run Glue Spark job"
    StartAt = "StartCrawler"
    States = {
      StartCrawler = {
        Type       = "Task"
        Resource   = "arn:aws:states:::aws-sdk:glue:startCrawler"
        Parameters = { Name = aws_glue_crawler.raw.name }
        Retry = [{
          ErrorEquals     = ["Glue.CrawlerRunningException"]
          IntervalSeconds = 15
          MaxAttempts     = 3
          BackoffRate     = 2.0
        }]
        Next = "WaitForCrawler"
      }
      WaitForCrawler = {
        Type    = "Wait"
        Seconds = 20
        Next    = "GetCrawler"
      }
      GetCrawler = {
        Type       = "Task"
        Resource   = "arn:aws:states:::aws-sdk:glue:getCrawler"
        Parameters = { Name = aws_glue_crawler.raw.name }
        Next       = "CrawlerDone?"
      }
      "CrawlerDone?" = {
        Type = "Choice"
        Choices = [{
          Variable     = "$.Crawler.State"
          StringEquals = "READY"
          Next         = "RunGlueJob"
        }]
        Default = "WaitForCrawler"
      }
      RunGlueJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.approvals_spark.name
        }
        Retry = [{
          ErrorEquals     = ["States.ALL"]
          IntervalSeconds = 30
          MaxAttempts     = 1
          BackoffRate     = 2.0
        }]
        End = true
      }
    }
  })
}
