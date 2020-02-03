locals {

  push_docker = (var.ecr_repo_name != null)
  docker_build_and_push = [
    "export ECR_TAG_NAME=`date +\"%Y-%m-%d_%H-%M-%S\"`",            //TODO: Add the ability to give different tag?
    "$(aws ecr get-login --no-include-email --region $AWS_REGION)", // TODO: Region?
    "ECR_IMAGE_NAME=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${var.ecr_repo_name}:$ECR_TAG_NAME",
    "docker build . -t $ECR_IMAGE_NAME",
    "docker push $ECR_IMAGE_NAME",
    "echo \"image_tag = \\\"$ECR_TAG_NAME\\\"\" > terraform.tfvars"
  ]

  docker_artifacts = [
    "*.tfvars"
  ]

  normal_cache = [
    "/root/cache/**/*"
  ]

  build_spec = {
    version = "0.2"
    phases = {
      install = {
        runtime-versions = merge({ docker = "18" }, var.runtimes)
        commands         = []
      }
      build = {
        commands = concat(
          var.pre_script,
          local.push_docker ? local.docker_build_and_push : [],
          var.post_script
        )
      }
    }
    artifacts = {
      files = concat(var.artifacts, local.push_docker ? local.docker_artifacts : [])
    }
    cache = {
      paths = local.normal_cache
    }
  }
}