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

resource "arcane_global_variable" "stirling_security_initiallogin_password" {
  count = var.enable_stirling_pdf ? 1 : 0

  key              = "SECURITY_INITIALLOGIN_PASSWORD"
  value_wo         = var.stirling_security_initiallogin_password
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "gitea_mirror_better_auth_secret" {
  count = var.enable_gitea_mirror ? 1 : 0

  key              = "BETTER_AUTH_SECRET"
  value_wo         = var.better_auth_secret
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "gitea_db_password" {
  count = var.enable_gitea ? 1 : 0

  key              = "GITEA_DB_PASSWORD"
  value_wo         = var.gitea_db_password
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "homarr_secret_encryption_key" {
  count = var.enable_homarr ? 1 : 0

  key              = "SECRET_ENCRYPTION_KEY"
  value_wo         = var.homarr_secret_encryption_key
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "rackula_api_write_token" {
  count = var.enable_rackula ? 1 : 0

  key              = "RACKULA_API_WRITE_TOKEN"
  value_wo         = var.rackula_api_write_token
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "rackula_auth_session_secret" {
  count = var.enable_rackula && var.rackula_auth_mode != "none" ? 1 : 0

  key              = "RACKULA_AUTH_SESSION_SECRET"
  value_wo         = var.rackula_auth_session_secret
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "rackula_local_password" {
  count = var.enable_rackula && var.rackula_auth_mode == "local" ? 1 : 0

  key              = "RACKULA_LOCAL_PASSWORD"
  value_wo         = var.rackula_local_password
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "hermes_discord_bot_token" {
  count = var.enable_hermes_agent ? 1 : 0

  key              = "DISCORD_BOT_TOKEN"
  value_wo         = var.hermes_discord_bot_token
  value_wo_version = 1

  is_secret              = true
  all_environments       = false
  environment_ids        = ["0"]
  inject_into_containers = false
}

resource "arcane_global_variable" "hermes_dashboard_password" {
  count = var.enable_hermes_agent ? 1 : 0

  key              = "HERMES_DASHBOARD_BASIC_AUTH_PASSWORD"
  value_wo         = var.hermes_dashboard_password
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

resource "arcane_gitops_sync" "stirling_pdf" {
  depends_on = [arcane_global_variable.stirling_security_initiallogin_password]
  count      = var.enable_stirling_pdf ? 1 : 0

  environment_id = "0"
  name           = "stirling-pdf"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/stirling-pdf/docker-compose.yml"
  project_name   = "stirling-pdf"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH                   = var.docker_base_path
    DOCKER_ENABLE_SECURITY             = "true"
    INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "false"
    METRICS_ENABLED                    = "true"
    PGID                               = tostring(var.pgid)
    PUID                               = tostring(var.puid)
    SECURITY_CSRFDISABLED              = var.stirling_csrf_disabled
    SECURITY_ENABLELOGIN               = "true"
    SECURITY_INITIALLOGIN_USERNAME     = var.stirling_security_initiallogin_username
    SYSTEM_DEFAULTLOCALE               = "en-US"
    SYSTEM_GOOGLEVISIBILITY            = "false"
    SYSTEM_MAXFILESIZE                 = "2000"
    TRAEFIK_BASE_DOMAIN                = var.traefik_base_domain
    TZ                                 = "America/Los_Angeles"
  }
}

resource "arcane_gitops_sync" "gitea_mirror" {
  depends_on = [arcane_global_variable.gitea_mirror_better_auth_secret]
  count      = var.enable_gitea_mirror ? 1 : 0

  environment_id = "0"
  name           = "gitea-mirror"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/gitea-mirror/docker-compose.yml"
  project_name   = "gitea-mirror"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PGID                = tostring(var.pgid)
    PUID                = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }
}

resource "arcane_gitops_sync" "gitea" {
  depends_on = [arcane_global_variable.gitea_db_password]
  count      = var.enable_gitea ? 1 : 0

  environment_id = "0"
  name           = "gitea"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/gitea/docker-compose.yml"
  project_name   = "gitea"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DOCKER_BASE_PATH    = var.docker_base_path
    GITEA_DB_NAME       = var.gitea_db_name
    GITEA_DB_USER       = var.gitea_db_user
    PGID                = tostring(var.pgid)
    PUID                = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    TZ                  = "America/Los_Angeles"
  }
}

resource "arcane_gitops_sync" "homarr" {
  depends_on = [arcane_global_variable.homarr_secret_encryption_key]
  count      = var.enable_homarr ? 1 : 0

  environment_id = "0"
  name           = "homarr"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/homarr/docker-compose.yml"
  project_name   = "homarr"

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

resource "arcane_gitops_sync" "rackula" {
  depends_on = [
    arcane_global_variable.rackula_api_write_token,
    arcane_global_variable.rackula_auth_session_secret,
    arcane_global_variable.rackula_local_password,
  ]
  count = var.enable_rackula ? 1 : 0

  environment_id = "0"
  name           = "rackula"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/rackula/docker-compose.yml"
  project_name   = "rackula"

  auto_sync           = true
  sync_interval       = 60
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    ALLOW_INSECURE_CORS                = "false"
    DOCKER_BASE_PATH                   = var.docker_base_path
    PGID                               = tostring(var.pgid)
    PUID                               = tostring(var.puid)
    RACKULA_API_PORT                   = var.rackula_api_port
    RACKULA_AUTH_MODE                  = var.rackula_auth_mode
    RACKULA_AUTH_SESSION_COOKIE_SECURE = "true"
    RACKULA_LOCAL_USERNAME             = var.rackula_local_username
    TRAEFIK_BASE_DOMAIN                = var.traefik_base_domain
  }
}

resource "arcane_gitops_sync" "hermes_agent" {
  depends_on = [
    arcane_global_variable.hermes_discord_bot_token,
    arcane_global_variable.hermes_dashboard_password,
  ]
  count = var.enable_hermes_agent ? 1 : 0

  environment_id = "0"
  name           = "hermes-agent"
  repository_id  = arcane_git_repository.homelab.id
  branch         = "main"
  compose_path   = "docker/hermes-agent/docker-compose.yml"
  project_name   = "hermes-agent"

  auto_sync           = true
  sync_interval       = 60
  sync_directory      = true
  start_project       = true
  fail_if_name_exists = true
  environment_variables = {
    DISCORD_ALLOWED_USERS                = var.hermes_discord_allowed_users
    DOCKER_BASE_PATH                     = var.docker_base_path
    HERMES_DASHBOARD_BASIC_AUTH_USERNAME = var.hermes_dashboard_username
    HERMES_TRUSTED_PROXY                 = var.hermes_trusted_proxy
    PGID                                 = tostring(var.pgid)
    PUID                                 = tostring(var.puid)
    TRAEFIK_BASE_DOMAIN                  = var.traefik_base_domain
    TZ                                   = "America/Los_Angeles"
  }
}
