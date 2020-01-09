![Latest Version](https://img.shields.io/github/v/release/byu-oit/terraform-aws-codepipeline?sort=semver)

# Terraform AWS CodePipeline Module

Creates a CodePipeline for a project. The pipeline it creates has the following stages:

1. *Source*: Pulls from a source GitHub repo in the byu-oit organization and branch.
2. *Build*: Builds based on the buildspec.yml in the project.
3. *Deploy*: Deploys the project. The user can specify the [deployment provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html) and [deployment configuration](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements).
    * **Note:** if `deploy_provider` and `deploy_configuration` are not specified then the pipeline will not have a deploy stage.

## Usage
```hcl
module "codepipeline" {
  source = "git@github.com:byu-oit/terraform-aws-codepipeline?ref=v1.2.0"
  app_name        = "example"
  repo_name       = "test"
  branch          = "dev"
  github_token    = module.acs.github_token
  deploy_provider = "S3"
  deploy_configuration = {
    BucketName = "test-bucket-${data.aws_caller_identity.current.account_id}"
    Extract    = true
  }
  account_env                   = "dev"
  env_tag                       = "dev"
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
  power_builder_role_arn        = module.acs.power_builder_role.arn
}
```

## Requirements
* Terraform version 0.12.16 or greater

## Inputs
| Name | Type |Description | Default |
| --- | --- | --- | --- |
| app_name | string | The name of the application. |
| account_env | string | The environment (dev/prd) of the account you're deploying to (should match the ACS module). |
| env_tag | string | The environment tag for the resources. |
| data_sensitivity_tag | string | The data-sensitivity tag for the resources. | confidential |
| repo_name | string | The name of the repository of the project. |
| branch | string | The name of the branch you want to trigger the pipeline. |
| deploy_provider | string | The provider for the deploy stage of the pipeline. If set to null this will skip setting up a deploy phase. | null |
| deploy_configuration | any | The configuration for the deploy provider. If set to null this will skip setting up a deploy phase. | null |
| build_buildspec | string | The file to use for the build phase. | buildspec.yml |
| role_permissions_boundary_arn | string | The role permissions boundary ARN. |
| github_token | string | The GitHub token associated with the AWS account. |
| power_builder_role_arn | string | The ARN for the PowerBuilder role. |

## Outputs
| Name | Type | Description |
| --- | --- | --- |
| codepipeline | [object](https://www.terraform.io/docs/providers/aws/r/codepipeline.html#argument-reference) | The CodePipeline object |
