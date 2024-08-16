variable "pipeline_name" {
  description = "The name of the CodePipeline"
  type        = string
}

variable "source_repo" {
  description = "The source repository for the pipeline"
  type        = string
}

variable "build_project" {
  description = "The build project for the pipeline"
  type        = string
}

variable "deployment_group" {
  description = "The deployment group for the pipeline"
  type        = string
}

resource "aws_codepipeline" "pipeline" {
  name = var.pipeline_name

  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.source_repo
        BranchName     = "test-branch"
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
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.build_project
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ApplicationName     = var.deployment_group
        DeploymentGroupName = var.deployment_group
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.pipeline_name}-bucket"
}

output "pipeline_name" {
  value = aws_codepipeline.pipeline.name
}