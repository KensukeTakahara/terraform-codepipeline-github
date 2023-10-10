resource "aws_codepipeline" "example" {
  name     = var.service_name
  role_arn = aws_iam_role.codepipeline.arn

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = 1
      output_artifacts = ["Source"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = var.repository
        BranchName           = var.branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        DetectChanges        = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = var.codebuild_project_id
      }
    }
  }

  # stage {
  #   name = "Deploy"

  #   action {
  #     name            = "Deploy"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "ECS"
  #     version         = 1
  #     input_artifacts = ["Build"]

  #     configuration = {
  #       ClusterName = var.ecs_cluster_name
  #       ServiceName = var.ecs_service_name
  #       FileName    = "imagedefinitions.json"
  #     }
  #   }
  # }

  artifact_store {
    location = var.bucket_id
    type     = "S3"
  }
}

resource "aws_codepipeline_webhook" "bar" {
  name            = "test-webhook-github"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.example.name

  authentication_configuration {
    secret_token = "foobar"
  }

  # This does the trick! CodePipeline starts when a GitHub release is created!
  filter {
    # json_path = "$.ref"
    # match_equals = "refs/tags/v.*"
    json_path    = "$.action"
    match_equals = "published"
  }
}
