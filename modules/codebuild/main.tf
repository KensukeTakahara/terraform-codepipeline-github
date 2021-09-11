data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

resource "aws_codebuild_project" "main" {
  name         = var.service_name
  service_role = aws_iam_role.codebuild.arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.self.account_id
    }

    environment_variable {
      name  = "IMAGE"
      value = "${var.service_name}:latest"
    }
  }
}
