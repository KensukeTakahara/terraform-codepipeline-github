data "aws_iam_policy_document" "s3" {
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
}

resource "aws_iam_policy" "s3" {
  name   = "${var.service_name}-codepipeline-s3-policy"
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect    = "Allow"
    resources = [var.codebuild_project_arn]

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "${var.service_name}-codepipeline-codebuild-policy"
  policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "ecs" {
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
}

resource "aws_iam_policy" "ecs" {
  name   = "${var.service_name}-codepipeline-ecs-policy"
  policy = data.aws_iam_policy_document.ecs.json
}

data "aws_iam_policy_document" "iam" {
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
}

resource "aws_iam_policy" "iam" {
  name   = "${var.service_name}-codepipeline-iam-policy"
  policy = data.aws_iam_policy_document.iam.json
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
  name   = "${var.service_name}-codepipeline-codestar-connection-policy"
  policy = data.aws_iam_policy_document.codestar_connection.json
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

resource "aws_iam_role_policy_attachment" "codepipeline_s3" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codebuild.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.ecs.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_iam" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.iam.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codestar_connection" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codestar_connection.arn
}
