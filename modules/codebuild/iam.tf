data "aws_iam_policy_document" "s3" {
  statement {
    effect    = "Allow"
    resources = [var.bucket_arn, "${var.bucket_arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name   = "${var.service_name}-codebuild-s3-policy"
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "logs" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_policy" "logs" {
  name   = "${var.service_name}-codebuild-logs-policy"
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitializeLayerGroup",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name   = "${var.service_name}-codebuild-ecr-policy"
  policy = data.aws_iam_policy_document.ecr.json
}

data "aws_iam_policy_document" "codestar_connection" {
  statement {
    effect    = "Allow"
    resources = [var.codestar_connection_arn]

    actions = [
      "codestar-connections:UseConnection"
    ]
  }
}

resource "aws_iam_policy" "codestar_connection" {
  name   = "${var.service_name}-codebuild-codestar-connection-policy"
  policy = data.aws_iam_policy_document.codestar_connection.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.service_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.ecr.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_codestar_connection" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codestar_connection.arn
}
