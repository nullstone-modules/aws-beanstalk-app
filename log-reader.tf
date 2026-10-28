locals {
  log_group = "/aws/elasticbeanstalk/${local.beanstalk_env}/*"
}
resource "aws_iam_user" "log_reader" {
  name = "log-reader-${local.resource_name}"
  tags = local.tags
}

resource "aws_iam_access_key" "log_reader" {
  user = aws_iam_user.log_reader.name
}

resource "aws_iam_user_policy" "log_reader" {
  name   = "AllowReadLogs"
  user   = aws_iam_user.log_reader.name
  policy = data.aws_iam_policy_document.log_reader.json
}

data "aws_iam_policy_document" "log_reader" {
  statement {
    sid    = "AllowReadLogs"
    effect = "Allow"

    actions = [
      "logs:Get*",
      "logs:List*",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:TestMetricFilter",
      "logs:Filter*"
    ]

    // Log Group actions (FilterLogEvents, StartQuery, ...) require the Log Group ARN as of 2027-04-26.
    // The Log Stream ARN stays for the stream-scoped actions (GetLogEvents).
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.this.account_id}:log-group:${local.log_group}",
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.this.account_id}:log-group:${local.log_group}:log-stream:*",
    ]
  }
}