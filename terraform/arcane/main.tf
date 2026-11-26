resource "arcane_git_repository" "homelab" {
  name      = "homelab-gitops"
  url       = var.repo_url
  auth_type = "none"
  enabled   = true
}

resource "arcane_global_variable" "pilot_secret_canary" {
  count = var.enable_pilot ? 1 : 0

  key              = "ARCANE_PILOT_SECRET_CANARY"
  value_wo         = "not-a-secret-rotated-test-value"
  value_wo_version = 2

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_gitops_sync" "pilot" {
  count = var.enable_pilot ? 1 : 0

  environment_id = "0"
  name           = "arcane-pilot"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/arcane-pilot/docker-compose.yml"
  project_name   = "arcane-pilot"

  auto_sync           = true
  sync_interval       = 60
  sync_directory      = true
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    ARCANE_PILOT_VALUE  = var.pilot_value
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
  }
}

resource "arcane_gitops_sync" "it_tools" {
  count = var.enable_it_tools ? 1 : 0

  environment_id = "0"
  name           = "it-tools"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/it-tools/docker-compose.yml"
  project_name   = "it-tools"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
  }
}

resource "arcane_gitops_sync" "ombi" {
  count = var.enable_ombi ? 1 : 0

  environment_id = "0"
  name           = "ombi"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/ombi/docker-compose.yml"
  project_name   = "ombi"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PGID                = tostring(var.pgid)
    PUID                = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
  }
}
