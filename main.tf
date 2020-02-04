terraform {
  required_version = ">= 0.12.16"
  required_providers {
    aws = ">= 2.42"
  }
}

data "aws_caller_identity" "current" {}

locals {
  tags = merge(var.tags, {
    env              = var.env_tag
    data-sensitivity = var.data_sensitivity_tag
    repo             = "https://github.com/${var.github_owner}/${var.github_repo}"
  })
  has_deploy_stage    = var.deploy_provider != null && var.deploy_configuration != null
  has_terraform_stage = var.terraform_application_path != "" && var.terraform_application_path != null

  build_env_vars = merge(var.build_env_variables, {
    AWS_ACCOUNT_ID            = data.aws_caller_identity.current.account_id
    TERRAFORM_APPLICATION_DIR = var.terraform_application_path
    TF_CLI_ARGS               = "-no-color" //TODO: Only in terraform build probably
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name                 = "${var.app_name}-codepipeline-role"
  permissions_boundary = var.role_permissions_boundary_arn
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.app_name}-codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codedeploy:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


//https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html
resource "aws_codepipeline" "pipeline" {
  name     = "${var.app_name}-${var.pipline_environment}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "byu-oit"
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
        //If this is not set then webhook and polling cause the pipeline to run (running everything twice)
        PollForSourceChanges = false
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  dynamic "stage" {
    for_each = local.has_terraform_stage ? [1] : []
    content {
      name = "Terraform"
      action {
        name             = "Terraform"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["build_output"]
        output_artifacts = ["terraform_output"]
        version          = "1"

        configuration = {
          ProjectName = aws_codebuild_project.deploy_build_project[0].name
        }
      }
    }
  }

  dynamic "stage" {
    for_each = local.has_deploy_stage ? [1] : []
    content {
      name = "Deploy"
      action {
        category        = "Deploy"
        name            = "Deploy"
        owner           = "AWS"
        provider        = var.deploy_provider
        version         = "1"
        input_artifacts = ["terraform_output"]
        configuration   = var.deploy_configuration
      }
    }
  }

  lifecycle {
    ignore_changes = [
      stage[0].action[0].configuration // ignore GitHub's OAuthToken
    ]
  }

  tags = local.tags
}

resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.app_name}-${var.pipline_environment}-codepipeline-cache-${data.aws_caller_identity.current.account_id}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      lifecycle_rule
    ]
  }
}

resource "aws_codebuild_project" "build_project" {
  name         = "${var.app_name}-${var.pipline_environment}-Build"
  service_role = var.power_builder_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.build_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

  }
  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_bucket.bucket}/build/cache"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_buildspec
  }

  tags = local.tags
}

module "terraform_buildspec" {
  source                 = "./terraform-buildspec-helper"
  export_appspec = (var.deploy_provider == "CodeDeploy")
}

resource "aws_codebuild_project" "deploy_build_project" {
  count        = local.has_terraform_stage ? 1 : 0
  name         = "${var.app_name}-${var.pipline_environment}-TerraformDeploy"
  service_role = var.power_builder_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.build_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }
  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_bucket.bucket}/deploy/cache"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = module.terraform_buildspec.script
  }
  tags = local.tags
}

//TODO: Slack notification?

