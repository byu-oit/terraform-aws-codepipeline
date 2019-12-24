provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

data "aws_caller_identity" "current" {}

module "codepipeline" {
  source   = "../"
  app_name = "cp-test"
  branch   = "dev"
  deploy_configuration = {
    BucketName = "test-bucket-${data.aws_caller_identity.current.account_id}"
    Extract    = true
  }
  deploy_provider = "S3"
  repo_name       = "test"
}

resource "aws_s3_bucket" "test" {
  bucket = "test-bucket-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    ignore_changes = [
      lifecycle_rule
    ]
  }
}
