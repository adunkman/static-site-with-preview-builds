resource "aws_iam_user" "preview_deployer" {
  name = "preview_deployer"
}

resource "aws_iam_user_policy" "access" {
  user = aws_iam_user.preview_deployer.name
  policy = data.aws_iam_policy_document.allow_preview_access.json
}

data "aws_iam_policy_document" "allow_preview_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = ["${var.preview_s3_arn}/*"]
  }
}
