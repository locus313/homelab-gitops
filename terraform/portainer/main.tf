# ---------------------------------------------------------------------------
# Locals — computed values shared across multiple stacks
# ---------------------------------------------------------------------------

locals {
  # String-typed user/group IDs for env blocks (Portainer env values are strings)
  puid_str = tostring(var.puid)
  pgid_str = tostring(var.pgid)

  # Fully-qualified URLs derived from base domain
  zerobyte_base_url = "https://zerobyte.${var.traefik_base_domain}"

  # Portainer-managed filesystem paths for stacks that use relative bind mounts.
  # Portainer clones/syncs the stack directory here on each GitOps update so
  # Docker can resolve ./relative paths against a stable host path.
  # Must be OUTSIDE the cloud-init clone (/opt/homelab-gitops) to avoid
  # git-repo-within-git-repo conflicts on Portainer's git pull.
  traefik_fs_path = "${var.portainer_stack_path}/traefik"
}

# ---------------------------------------------------------------------------
# Traefik — reverse proxy and SSL termination (deploy first)
#
# support_relative_path = true lets Portainer keep docker/traefik/* synced to
# filesystem_path on the Docker host. On each 1-hour GitOps poll Portainer
# pulls the latest commits and refreshes that directory, so ./config always
# reflects the current repo state when the container restarts.
# ---------------------------------------------------------------------------

resource "portainer_stack" "traefik" {
  name            = "traefik"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/traefik/docker-compose.yml"

  support_relative_path = true
  filesystem_path       = local.traefik_fs_path

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "CLOUDNS_SUB_AUTH_ID"
    value = var.cloudns_sub_auth_id
  }
  env {
    name  = "CLOUDNS_AUTH_PASSWORD"
    value = var.cloudns_auth_password
  }
  env {
    name  = "CLOUDNS_PROPAGATION_TIMEOUT"
    value = var.cloudns_propagation_timeout
  }
  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "NAS_IP"
    value = var.nas_ip
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "TZ"
    value = var.tz
  }
}

# ---------------------------------------------------------------------------
# Portainer EE — NOTE: Portainer is bootstrapped manually and NOT managed
# here to avoid a chicken-and-egg dependency. This workspace requires
# Portainer to be running before `terraform apply` can succeed.
#
# If you want Terraform to own the Portainer stack after initial bootstrap,
# import the running stack:
#   terraform import portainer_stack.portainer <stack-id>
#
# resource "portainer_stack" "portainer" { ... }
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Home Assistant
# ---------------------------------------------------------------------------

resource "portainer_stack" "home_assistant" {
  name            = "home-assistant"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/home-assistant/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Plex — media server (network_mode: host)
# ---------------------------------------------------------------------------

resource "portainer_stack" "plex" {
  name            = "plex"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/plex/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "PLEX_CLAIM"
    value = var.plex_claim
  }
  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "MEDIA_PATH"
    value = var.media_path
  }
}

# ---------------------------------------------------------------------------
# Gitea — self-hosted Git service
# ---------------------------------------------------------------------------

resource "portainer_stack" "gitea" {
  name            = "gitea"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/gitea/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "GITEA_DB_NAME"
    value = var.gitea_db_name
  }
  env {
    name  = "GITEA_DB_USER"
    value = var.gitea_db_user
  }
  env {
    name  = "GITEA_DB_PASSWORD"
    value = var.gitea_db_password
  }
}

# ---------------------------------------------------------------------------
# Gitea Mirror — repository mirroring service
# ---------------------------------------------------------------------------

resource "portainer_stack" "gitea_mirror" {
  name            = "gitea-mirror"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/gitea-mirror/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "BETTER_AUTH_SECRET"
    value = var.better_auth_secret
  }
}

# ---------------------------------------------------------------------------
# Homarr — homelab dashboard
# ---------------------------------------------------------------------------

resource "portainer_stack" "homarr" {
  name            = "homarr"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/homarr/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "SECRET_ENCRYPTION_KEY"
    value = var.homarr_secret_encryption_key
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Beszel — lightweight server monitoring hub
# ---------------------------------------------------------------------------

resource "portainer_stack" "beszel" {
  name            = "beszel"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/beszel/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "BESZEL_PUBLIC_KEY"
    value = var.beszel_public_key
  }
  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Zerobyte — backup management
# ---------------------------------------------------------------------------

resource "portainer_stack" "zerobyte" {
  name            = "zerobyte"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/zerobyte/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "APP_SECRET"
    value = var.zerobyte_app_secret
  }
  env {
    name  = "BASE_URL"
    value = local.zerobyte_base_url
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# IT Tools — developer utilities
# ---------------------------------------------------------------------------

resource "portainer_stack" "it_tools" {
  name            = "it-tools"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/it-tools/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Stirling PDF — PDF manipulation toolkit
# ---------------------------------------------------------------------------

resource "portainer_stack" "stirling_pdf" {
  name            = "stirling-pdf"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/stirling-pdf/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "DOCKER_ENABLE_SECURITY"
    value = "true"
  }
  env {
    name  = "SECURITY_ENABLELOGIN"
    value = "true"
  }
  env {
    name  = "SECURITY_INITIALLOGIN_USERNAME"
    value = var.stirling_security_initiallogin_username
  }
  env {
    name  = "SECURITY_INITIALLOGIN_PASSWORD"
    value = var.stirling_security_initiallogin_password
  }
  env {
    name  = "SECURITY_CSRFDISABLED"
    value = "true"
  }
  env {
    name  = "INSTALL_BOOK_AND_ADVANCED_HTML_OPS"
    value = "false"
  }
  env {
    name  = "METRICS_ENABLED"
    value = "true"
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "SYSTEM_DEFAULTLOCALE"
    value = "en-US"
  }
  env {
    name  = "SYSTEM_MAXFILESIZE"
    value = "2000"
  }
  env {
    name  = "SYSTEM_GOOGLEVISIBILITY"
    value = "false"
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# MeTube — yt-dlp web interface
# ---------------------------------------------------------------------------

resource "portainer_stack" "metube" {
  name            = "metube"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/metube/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "OUTPUT_TEMPLATE"
    value = var.metube_output_template
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "UMASK"
    value = "002"
  }
  env {
    name  = "YTDL_OPTIONS"
    value = var.metube_ytdl_options
  }
  env {
    name  = "MEDIA_PATH"
    value = var.media_path
  }
}

# ---------------------------------------------------------------------------
# HandBrake — video transcoder with GPU acceleration
# ---------------------------------------------------------------------------

resource "portainer_stack" "handbrake" {
  name            = "handbrake"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/handbrake/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "UMASK"
    value = "0022"
  }
  env {
    name  = "MEDIA_PATH"
    value = var.media_path
  }
  env {
    name  = "BACKUP_PATH"
    value = var.backup_path
  }
}

# ---------------------------------------------------------------------------
# NetbootXYZ — network boot service
# ---------------------------------------------------------------------------

resource "portainer_stack" "netbootxyz" {
  name            = "netbootxyz"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/netbootxyz/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "NGINX_PORT"
    value = "80"
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "WEB_APP_PORT"
    value = "3000"
  }
}

# ---------------------------------------------------------------------------
# iVentoy — ISO network boot server
# Not currently deployed (conflicts with NetbootXYZ on port 69/udp TFTP).
# To enable: uncomment and remove the port 69 line from docker/iventoy/docker-compose.yml,
# or accept that TFTP won't be available for iVentoy clients.
#
# resource "portainer_stack" "iventoy" { ... }
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Rackula — infrastructure documentation
# ---------------------------------------------------------------------------

resource "portainer_stack" "rackula" {
  name            = "rackula"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/rackula/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "DOCKER_BASE_PATH"
    value = var.docker_base_path
  }
  env {
    name  = "PUID"
    value = local.puid_str
  }
  env {
    name  = "PGID"
    value = local.pgid_str
  }
  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "TRAEFIK_BASE_DOMAIN"
    value = var.traefik_base_domain
  }
  env {
    name  = "RACKULA_API_PORT"
    value = var.rackula_api_port
  }
  env {
    name  = "RACKULA_API_WRITE_TOKEN"
    value = var.rackula_api_write_token
  }
  env {
    name  = "RACKULA_AUTH_MODE"
    value = var.rackula_auth_mode
  }
  env {
    name  = "RACKULA_AUTH_SESSION_SECRET"
    value = var.rackula_auth_session_secret
  }
  env {
    name  = "RACKULA_LOCAL_USERNAME"
    value = var.rackula_local_username
  }
  env {
    name  = "RACKULA_LOCAL_PASSWORD"
    value = var.rackula_local_password
  }
  env {
    name  = "RACKULA_AUTH_SESSION_COOKIE_SECURE"
    value = "true"
  }
  env {
    name  = "ALLOW_INSECURE_CORS"
    value = "false"
  }
}

# ---------------------------------------------------------------------------
# Watchtower — automated container image updates
# ---------------------------------------------------------------------------

resource "portainer_stack" "watchtower" {
  name            = "watchtower"
  deployment_type = "standalone"
  method          = "repository"
  endpoint_id     = var.portainer_endpoint_id

  repository_url            = var.repo_url
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "docker/watchtower/docker-compose.yml"

  update_interval = "1h"
  pull_image      = true
  prune           = true

  env {
    name  = "TZ"
    value = var.tz
  }
  env {
    name  = "WATCHTOWER_CLEANUP"
    value = var.watchtower_cleanup
  }
}
