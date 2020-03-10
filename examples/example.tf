provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

data "aws_caller_identity" "current" {}

variable "account_env" {
  default = "dev"
}

module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v1.2.1"
  env    = var.account_env
}
module "codepipeline" {
//  source = "../"
  source = "github.com/byu-oit/terraform-aws-codepipeline?ref=v1.2.2"
  app_name = "cp-test"
  branch   = "dev"
  deploy_configuration = {
    BucketName = "test-bucket-${data.aws_caller_identity.current.account_id}"
    Extract    = true
  }
  deploy_provider               = "S3"
  repo_name                     = "test"
  repo_owner                    = "byu-oit"
  account_env                   = var.account_env
  env_tag                       = "dev"
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
  github_token                  = module.acs.github_token
  power_builder_role_arn        = module.acs.power_builder_role.arn
}

resource "aws_s3_bucket" "test" {
  bucket = "test-bucket-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    ignore_changes = [
      lifecycle_rule
    ]
  }
}
