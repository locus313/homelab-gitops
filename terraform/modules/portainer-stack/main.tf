# Portainer Stack Module - GitOps stack deployed from this repository's main branch
#
# Owns the settings every stack shares: standalone deployment from refs/heads/main,
# hourly poll, image pull and prune on update, and the TZ environment variable.

locals {
  merged_env      = merge({ TZ = var.tz }, var.env)
  secret_env_keys = nonsensitive(keys(var.secret_env))
}

resource "portainer_stack" "this" {
  name            = var.name
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = var.compose_path

  support_relative_path = var.support_relative_path ? true : null
  filesystem_path       = var.filesystem_path

  update_interval = "1h"
  pull_image      = true
  prune           = true

  dynamic "env" {
    for_each = local.merged_env
    content {
      name  = env.key
      value = env.value
    }
  }

  dynamic "env" {
    for_each = local.secret_env_keys
    content {
      name  = env.value
      value = var.secret_env[env.value]
    }
  }
}
