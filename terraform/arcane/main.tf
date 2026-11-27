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

resource "arcane_global_variable" "netdata_claim_token" {
  count = var.enable_netdata ? 1 : 0

  key              = "NETDATA_CLAIM_TOKEN"
  value_wo         = var.netdata_claim_token
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_gitops_sync" "handbrake" {
  count = var.enable_handbrake ? 1 : 0

  environment_id = "0"
  name           = "handbrake"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/handbrake/docker-compose.yml"
  project_name   = "handbrake"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    BACKUP_PATH         = var.backup_path
    DOCKER_BASE_PATH    = var.docker_base_path
    MEDIA_PATH          = var.media_path
    PGID                = tostring(var.pgid)
    PUID                = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
    UMASK               = "0022"
  }
}

resource "arcane_gitops_sync" "netbootxyz" {
  count = var.enable_netbootxyz ? 1 : 0

  environment_id = "0"
  name           = "netbootxyz"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/netbootxyz/docker-compose.yml"
  project_name   = "netbootxyz"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH    = var.docker_base_path
    NGINX_PORT          = "80"
    PGID                = tostring(var.pgid)
    PUID                = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
    WEB_APP_PORT        = "3000"
  }
}

resource "arcane_gitops_sync" "beszel" {
  count = var.enable_beszel ? 1 : 0

  environment_id = "0"
  name           = "beszel"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/beszel/docker-compose.yml"
  project_name   = "beszel"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    BESZEL_PUBLIC_KEY   = var.beszel_public_key
    DOCKER_BASE_PATH    = var.docker_base_path
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
  }
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

resource "arcane_gitops_sync" "metube" {
  count = var.enable_metube ? 1 : 0

  environment_id = "0"
  name           = "metube"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/metube/docker-compose.yml"
  project_name   = "metube"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH    = var.docker_base_path
    MEDIA_PATH          = var.media_path
    OUTPUT_TEMPLATE     = var.metube_output_template
    PGID                = tostring(var.pgid)
    PUID                = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
    UMASK               = "002"
    YTDL_OPTIONS        = var.metube_ytdl_options
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

resource "arcane_gitops_sync" "home_assistant" {
  count = var.enable_home_assistant ? 1 : 0

  environment_id = "0"
  name           = "home-assistant"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/home-assistant/docker-compose.yml"
  project_name   = "home-assistant"

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

resource "arcane_gitops_sync" "netdata" {
  depends_on = [arcane_global_variable.netdata_claim_token]
  count      = var.enable_netdata ? 1 : 0

  environment_id = "0"
  name           = "netdata"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/netdata/docker-compose.yml"
  project_name   = "netdata"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH    = var.docker_base_path
    NETDATA_CLAIM_ROOMS = var.netdata_claim_rooms
    NETDATA_CLAIM_URL   = var.netdata_claim_url
  }
}

resource "arcane_gitops_sync" "watchtower" {
  count = var.enable_watchtower ? 1 : 0

  environment_id = "0"
  name           = "watchtower"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/watchtower/docker-compose.yml"
  project_name   = "watchtower"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    TZ                 = "America/Los_Angeles"
    WATCHTOWER_CLEANUP = var.watchtower_cleanup
  }
}
