provider "aws" {
  region = "ap-southeast-1"
  version = "2.7.0"
}

#Add notification configuration to SNS Topic

resource "aws_sns_topic" "topic" {
  name = "s3-event-notification-topic-123"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:s3-event-notification-topic-123",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.bucket.arn}"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket" "bucket" {
  bucket = "snsandsqsandlambdabukettest123"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  topic {
    topic_arn     = "${aws_sns_topic.topic.arn}"
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}

## sns to sqs

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic-test123"
}

resource "aws_sqs_queue" "user_updates_queue" {
  name = "user-updates-queue-test1213"
}
resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.user_updates_queue.arn}\",\"maxReceiveCount\":4}"

  }

resource "aws_sqs_queue_policy" "test" {
  queue_url = "${aws_sqs_queue.user_updates_queue.id}"
  policy = "${data.aws_iam_policy_document.sqs_upload.json}"
}

data "aws_iam_policy_document" "sqs_upload" {
  policy_id = "snssqssqs"
  statement {
    actions = [
      "sqs:SendMessage",
    ]
    condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        "${aws_sns_topic.user_updates.arn}",
      ]
    }
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"]
    }
    resources = [
      "${aws_sqs_queue.user_updates_queue.arn}",
    ]
    sid = "snssqssqssns"
  }
}



##IAM for Lambda

resource "aws_iam_role" "example_lambda" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_lambda" {
  policy_arn = "${aws_iam_policy.example_lambda.arn}"
  role = "${aws_iam_role.example_lambda.name}"
}

resource "aws_iam_policy" "example_lambda" {
  policy = "${data.aws_iam_policy_document.example_lambda.json}"
}

data "aws_iam_policy_document" "example_lambda" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = ["arn:aws:sqs:*"]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:ap-southeast-1:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-southeast-1:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }
  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-southeast-1:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}


##sqs to Lambda

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.user_updates_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.example_lambda.arn}"
}

output "sqs_url" {
  value = "${aws_sqs_queue.user_updates_queue.id}"
}


##IAM for Lambda1


resource "aws_iam_role" "example_lambda1" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_lambda1" {
  policy_arn = "${aws_iam_policy.example_lambda1.arn}"
  role = "${aws_iam_role.example_lambda1.name}"
}

resource "aws_iam_policy" "example_lambda1" {
  policy = "${data.aws_iam_policy_document.example_lambda1.json}"
}

data "aws_iam_policy_document" "example_lambda1" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = ["arn:aws:sqs:*"]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:ap-southeast-1:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-southeast-1:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }
  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:ap-southeast-1:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}


##sqs to Lambda

resource "aws_lambda_event_source_mapping" "event_source_mapping1" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.terraform_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.example_lambda1.arn}"
}

output "sqs_url1" {
  value = "${aws_sqs_queue.terraform_queue.id}"
}

resource "aws_sqs_queue" "terraform_queue1" {
  name                      = "terraform-example-queue1"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.terraform_queue.arn}\",\"maxReceiveCount\":4}"

  }

  resource "aws_cloudwatch_metric_alarm" "dlq1_not_empty" {
  alarm_name          = "${aws_sqs_queue.terraform_queue.name}_not_empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 1800
  threshold           = 0
  statistic           = "Average"

  dimensions {
    QueueName = "${aws_sqs_queue.terraform_queue.name}"
  }

  #alarm_actions = ["${var.alarm_topic_arn}"]
}
