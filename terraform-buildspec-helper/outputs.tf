output "script" {
  value = yamlencode(local.terraform_build_spec)
}