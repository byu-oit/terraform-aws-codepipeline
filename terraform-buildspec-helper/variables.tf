variable "artifacts" {
  type = list(string)
  default = []
}

variable "runtimes" {
  type    = map(string)
  default = {}
}

variable "export_appspec" {
  type    = bool
  default = false
}