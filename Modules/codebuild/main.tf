variable "project_name" {
  description = "The name of the CodeBuild project"
  type        = string
}

variable "source_repo" {
  description = "The source repository for the build"
  type        = string
}

variable "build_environment" {
  description = "The build environment for the project"
  type        = string
}

resource "aws_codebuild_project" "build" {
  name          = var.project_name
  source {
    type      = "CODECOMMIT"
    location  = var.source_repo
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.build_environment
    type                        = "LINUX_CONTAINER"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  service_role = aws_iam_role.codebuild_role.arn
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

output "build_project_name" {
  value = aws_codebuild_project.build.name
}