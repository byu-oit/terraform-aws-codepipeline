variable "artifacts" {
  type = list(string)
  default = []
}

variable "runtimes" {
  type    = map(string)
  default = {}
}

variable "for_fargate_codedeploy" {
  type    = bool
  default = false
}