![Latest Version](https://img.shields.io/github/v/release/byu-oit/terraform-aws-codepipeline?sort=semver)

# Terraform AWS CodePipeline Module

Creates a CodePipeline for a project. The pipeline it creates has the following stages:

1. *Source*: Pulls from a source GitHub repo in the byu-oit organization and branch.
2. *Build*: Builds based on the buildspec.yml in the project.
3. *Deploy*: Deploys the project. The user must specify the [deployment provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html) and [deployment configuration](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements). 

## Usage
```hcl
module "codepipeline" {
  source = "git@github.com:byu-oit/terraform-aws-codepipeline?ref=v1.1.5"
}
```

## Inputs
| Name | Description | Default |
| --- | --- | --- |
| app_name | The name of the application. |
| account_env | The environment (dev/prd) of the account you're deploying to (should match the ACS module). |
| env_tag | The environment tag for the resources. |
| data_sensitivity_tag | The data-sensitivity tag for the resources. | confidential |
| repo_name | The name of the repository of the project. |
| branch | The name of the branch you want to trigger the pipeline. |
| deploy_provider | The provider for the deploy stage of the pipeline. |
| deploy_configuration | The configuration for the deploy provider. |
| build_buildspec | The file to use for the build phase. | buildspec.yml |
| role_permissions_boundary_arn | The role permissions boundary ARN. |
| github_token | The GitHub token associated with the AWS account. |
| power_builder_role_arn | The ARN for the PowerBuilder role. |

## Outputs
| Name | Description |
| --- | --- |
| codepipeline | The CodePipeline [object](https://www.terraform.io/docs/providers/aws/r/codepipeline.html#argument-reference) |
