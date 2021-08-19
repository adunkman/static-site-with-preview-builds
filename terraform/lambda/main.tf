data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "viewer_request" {
  function_name = "viewer_request"
  filename = data.archive_file.viewer_request.output_path
  source_code_hash = data.archive_file.viewer_request.output_base64sha256
  role = aws_iam_role.viewer_request.arn
  handler = "viewer-request.handler"
  runtime = "nodejs12.x"
  publish = true

  tracing_config {
    mode = "PassThrough"
  }
}

data "archive_file" "viewer_request" {
  type = "zip"
  output_path = "./lambda/viewer-request.zip"
  source_file = "./lambda/viewer-request.js"
}

resource "aws_iam_role" "viewer_request" {
  name = "viewer_request"
  assume_role_policy = data.aws_iam_policy_document.viewer_request_role.json
}

data "aws_iam_policy_document" "viewer_request_role" {
  statement {
    actions = [ "sts:AssumeRole" ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy_attachment" "viewer_request" {
  name = "viewer_request"
  roles = [ aws_iam_role.viewer_request.name ]
  policy_arn = aws_iam_policy.viewer_request.arn
}

resource "aws_iam_policy" "viewer_request" {
  name = "viewer_request"
  policy = data.aws_iam_policy_document.viewer_request_access.json
}

data "aws_iam_policy_document" "viewer_request_access" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }
}
