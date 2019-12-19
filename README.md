# Terraform AWS CodePipeline Module

Creates a CodePipeline for a project. The pipeline it creates has the following stages:

1. *Source*: Pulls from a source GitHub repo in the byu-oit organization and branch.
2. *Build*: Builds based on the buildspec.yml in the project.
3. *Deploy*: Deploys the project. The user must specify the [deployment provider](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html) and [deployment configuration](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements). 

## Usage
```hcl
module "codepipeline" {
  source = "git@github.com:byu-oit/terraform-aws-codepipeline?ref=v1.0.0"
}
```

## Inputs
| Name | Description | Default |
| --- | --- | --- |
| app_name | The name of the application. |
| repo_name | The name of the repository of the project. |
| branch | The name of the branch you want to d trigger the pipeline. |
| deploy_provider | The provider for the deploy stage of the pipeline. |
| deploy_configuration | The configuration for the deploy provider. |

## Outputs
| Name | Description |
| --- | --- |
| codepipeline | The codepipeline [object](https://www.terraform.io/docs/providers/aws/r/codepipeline.html#argument-reference) |
