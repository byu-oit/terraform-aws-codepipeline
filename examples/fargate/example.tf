provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}


module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v1.2.1"
  env    = "dev"
}

locals {
  terraform_application_path = "./terraform-dev/application/"
}

module "buildspec" {
  source        = "github.com/byu-oit/terraform-aws-basic-codebuild-helper?ref=v0.0.2"
  ecr_repo_name = "thebestoneever"
  artifacts = ["${local.terraform_application_path}*"]
}

//https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html
module "codepipeline" {
  //  source = "../"
  source = "../../" //TODO: Eventually move to standard

  //Pipeline Information (used for naming)
  app_name            = "parking-api" //Handelcodepipeline name
  pipline_environment = "dev"         //pipeline name

  //Github information
  github_repo   = "parking-v2"
  github_branch = "dev"
  github_token  = module.acs.github_token //TODO: Force use to provide. Handel figured it out

  build_buildspec = "buildspec.yml" //Or give a string of the contents of a builspec.yml file

  //TODO: Is there a better way to provide code deploy info?
  //Blue Green Deploy
  deploy_provider = "CodeDeploy"
  deploy_configuration = {
    ApplicationName     = "parking-api-codedeploy"
    DeploymentGroupName = "parking-api-deployment-group"
  }

  //Terraform information
  terraform_application_path = local.terraform_application_path //env to deploy

  //Tagging
  env_tag              = "dev"
  data_sensitivity_tag = "confidential"

  //TODO: Make users figure this out?
  //Permissions
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
  power_builder_role_arn        = module.acs.power_builder_role.arn
}
