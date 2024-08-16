provider "aws" {
    region = "us-east-1"
  
}

module "ec2" {
    source = "./EC2"   
}

module "codecommit" {
  source                = "./codecommit"
  repository_name       = "my-repo"
  repository_description = "My CodeCommit repository"
}

module "codebuild" {
  source          = "./codebuild"
  project_name    = "my-build-project"
  source_repo     = module.codecommit.repository_clone_url_http
  build_environment = "aws/codebuild/standard:4.0"
}

module "codedeploy" {
  source                = "./codedeploy"
  application_name      = "my-codedeploy-app"
  deployment_group_name = "my-deployment-group"
  target_instances      = ["my-ec2-instance"]
}

module "codepipeline" {
  source            = "./codepipeline"
  pipeline_name     = "my-pipeline"
  source_repo       = module.codecommit.repository_clone_url_http
  build_project     = module.codebuild.build_project_name
  deployment_group  = module.codedeploy.deployment_group_name
}

output "repository_url" {
  value = module.codecommit.repository_clone_url_http
}

output "build_project_name" {
  value = module.codebuild.build_project_name
}

output "pipeline_name" {
  value = module.codepipeline.pipeline_name
}