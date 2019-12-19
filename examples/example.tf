provider "aws" {
  version = "~> 2.42"
  region = "us-west-2"
}

module "codepipeline" {
  source = "../"
  app_name = "cp-test"
  branch = "dev"
  deploy_configuration = {
    BucketName = "test-bucket"
    Extract = true
  }
  deploy_provider = "S3"
  repo_name = "test"
}

resource "aws_s3_bucket" "test" {
  bucket = "test-bucket"
}
