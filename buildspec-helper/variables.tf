variable "pre_script" {
  type    = list(string)
  default = []
}

variable "post_script" {
  type    = list(string)
  default = []
}

variable "runtimes" {
  type    = map(string)
  default = {}
}

variable "ecr_repo_name" {
  type    = string
  default = ""
}

variable "artifacts" {
  type    = list(string)
  default = []
}
