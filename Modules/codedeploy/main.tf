variable "application_name" {
  description = "The name of the CodeDeploy application"
  type        = string
}

variable "deployment_group_name" {
  description = "The name of the CodeDeploy deployment group"
  type        = string
}

variable "target_instances" {
  description = "The target instances for deployment"
  type        = list(string)
}

resource "aws_codedeploy_app" "app" {
  name = var.application_name
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name = aws_codedeploy_app.app.name
  deployment_group_name = var.deployment_group_name
  service_role_arn = aws_iam_role.codedeploy_role.arn
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "web-server"
    }
  }
}

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.application_name}-codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.deployment_group.name
}
