provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v1.2.1"
  env    = "dev"
}

//https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html
module "codepipeline" {
  //  source = "../"
  source = "../terraform-aws-codepipeline"

  //Pipeline Information (used for naming)
  app_name            = "parking-api"
  pipline_environment = "dev"

  //Github information
  github_repo   = "parking-v2"
  github_branch = "dev"
  github_token  = module.acs.github_token


  //Custom build information
  custom_build_script = [
    "curl -s https://byu-oit.github.io/byu-apps-custom-cicd-resources/setup-codebuild -o /tmp/s && . /tmp/s",
    "byu-maven"
  ]
  custom_build_env = {
    java = "openjdk11"
  }

  build_env_variables = {
    APP_ENV      = "dev"
    MAVEN_CONFIG = "--settings /usr/share/java/maven-3/conf/settings.xml"
  }

  ecr_repo = "thebestoneever"

  //Blue Green Deploy
  deploy_provider = "CodeDeploy"
  deploy_configuration = {
    ApplicationName     = "parking-api-codedeploy"
    DeploymentGroupName = "parking-api-deployment-group"
  }

  //Terraform information
  terraform_application_path = "./terraform-dev/application/"

  //Tagging
  env_tag              = "dev"
  data_sensitivity_tag = "confidential"

  //Permissions
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
  power_builder_role_arn        = module.acs.power_builder_role.arn
}
