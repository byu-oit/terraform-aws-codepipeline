variable "app_name" {
  type        = string
  description = "The name of the application."
}

variable "account_env" {
  type        = string
  description = "The environment (dev/prd) of the account you're deploying to (should match the ACS module)."
}

variable "env_tag" {
  type        = string
  description = "The environment tag for the resources."
}

variable "data_sensitivity_tag" {
  type        = string
  default     = "confidential"
  description = "The data-sensitivity tag for the resources."
}

variable "repo_name" {
  type        = string
  description = "The name of the repository of the project."
}

variable "repo_owner" {
  type        = string
  description = "The name of the owner of the project."
  default     = "byu-oit"
}

variable "branch" {
  type        = string
  description = "The name of the branch you want to d trigger the pipeline."
}

variable "deploy_provider" {
  type        = string
  description = "The provider for the deploy stage of the pipeline."
  default     = null
}

variable "deploy_configuration" {
  type        = any
  description = "The configuration for the deploy provider."
  default     = null
}

variable "build_buildspec" {
  default     = "buildspec.yml"
  description = "The name of the buildspec file for the Build stage."
  type        = string
}

variable "role_permissions_boundary_arn" {
  type        = string
  description = "The role permissions boundary ARN."
}

variable "github_token" {
  type        = string
  description = "The GitHub token associated with the AWS account."
}

variable "power_builder_role_arn" {
  type        = string
  description = "The ARN for the PowerBuilder role."
}
