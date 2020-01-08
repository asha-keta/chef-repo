data "archive_file" "example_lambda" {
  type        = "zip"
  source_file = "${path.module}/example_lambda.js"
  output_path = "${path.module}/example_lambda.js.zip"
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda"
  handler = "example_lambda.handler"
  role = "${aws_iam_role.example_lambda.arn}"
  runtime = "nodejs8.10"

  filename = "${data.archive_file.example_lambda.output_path}"
  source_code_hash = "${data.archive_file.example_lambda.output_base64sha256}"

  timeout = 30
  memory_size = 128
}

data "archive_file" "example_lambda1" {
  type        = "zip"
  source_file = "${path.module}/example_lambda1.js"
  output_path = "${path.module}/example_lambda1.js.zip"
}

resource "aws_lambda_function" "example_lambda1" {
  function_name = "example_lambda1"
  handler = "example_lambda1.handler"
  role = "${aws_iam_role.example_lambda1.arn}"
  runtime = "nodejs8.10"

  filename = "${data.archive_file.example_lambda1.output_path}"
  source_code_hash = "${data.archive_file.example_lambda1.output_base64sha256}"

  timeout = 30
  memory_size = 128
}
