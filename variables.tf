variable "app_name" {
  type        = string
  description = "The name of the application."
}

variable "env" {
  type = string
  description = "The environment (dev/prd) of the account you're deploying to (should match the ACS module)."
}

variable "repo_name" {
  type        = string
  description = "The name of the repository of the project."
}

variable "branch" {
  type        = string
  description = "The name of the branch you want to d trigger the pipeline."
}

variable "deploy_provider" {
  type        = string
  description = "The provider for the deploy stage of the pipeline."
}

variable "deploy_configuration" {
  type        = any
  description = "The configuration for the deploy provider."
}

variable "build_buildspec" {
  default     = "buildspec.yml"
  description = "The name of the buildspec file for the Build stage."
  type        = string
}
