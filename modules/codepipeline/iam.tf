data "aws_iam_policy_document" "main" {
  statement {
    effect    = "Allow"
    resources = [var.bucket_arn, "${var.bucket_arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]
  }

  statement {
    effect    = "Allow"
    resources = [var.codebuild_project_arn]

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = ["iam:PassRole"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"

      values = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    effect    = "Allow"
    resources = [var.codestar_connection_arn]

    actions = [
      "codestar-connections:UseConnection"
    ]
  }
}

resource "aws_iam_policy" "main" {
  name   = "${var.service_name}-codepipeline-policy"
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${var.service_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.main.arn
}
