variable "repository_name" {
  description = "The name of the CodeCommit repository"
  type        = string
}

variable "repository_description" {
  description = "The description of the CodeCommit repository"
  type        = string
  default     = "Repository for CI/CD pipeline"
}

resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = var.repository_description
}

output "repository_clone_url_http" {
  value = aws_codecommit_repository.repo.clone_url_http
}