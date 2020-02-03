variable "app_name" {
  type        = string
  description = "The name of the application."
}

variable "env_tag" {
  type        = string
  description = "The environment tag for the resources."
}

variable "data_sensitivity_tag" {
  type        = string
  description = "The data-sensitivity tag for the resources."
}

variable "tags" {
  type        = map(string)
  description = "Tags for code pipeline"
  default = {}
}

variable "github_owner" {
  type    = string
  default = "byu-oit"
}

variable "github_repo" {
  type        = string
  description = "The name of the repository of the project."
}

variable "github_branch" {
  type        = string
  description = "The name of the branch you want to trigger the pipeline."
}
variable "pipline_environment" {
  type        = string
  description = "Pipline name"
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

variable "terraform_application_path" {
  type        = string
  default = ""
  description = "Relative path to the terraform application folder from the root (requires trailing slash)"
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

variable "build_env_variables" {
  type        = map(string)
  description = "environment variables for Build"
  default     = {}
}