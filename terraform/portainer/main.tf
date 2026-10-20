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

module "traefik" {
  source = "../modules/portainer-stack"

  name                  = "traefik"
  compose_path          = "docker/traefik/docker-compose.yml"
  endpoint_id           = var.portainer_endpoint_id
  repo_url              = var.repo_url
  tz                    = var.tz
  support_relative_path = true
  filesystem_path       = local.traefik_fs_path

  env = {
    CLOUDNS_PROPAGATION_TIMEOUT = var.cloudns_propagation_timeout
    DOCKER_BASE_PATH            = var.docker_base_path
    NAS_IP                      = var.nas_ip
    TRAEFIK_BASE_DOMAIN         = var.traefik_base_domain
  }

  secret_env = {
    CLOUDNS_SUB_AUTH_ID   = var.cloudns_sub_auth_id
    CLOUDNS_AUTH_PASSWORD = var.cloudns_auth_password
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

module "home_assistant" {
  source = "../modules/portainer-stack"

  name         = "home-assistant"
  compose_path = "docker/home-assistant/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Plex — media server (network_mode: host)
# ---------------------------------------------------------------------------

module "plex" {
  source = "../modules/portainer-stack"

  name         = "plex"
  compose_path = "docker/plex/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    PUID             = local.puid_str
    PGID             = local.pgid_str
    DOCKER_BASE_PATH = var.docker_base_path
    MEDIA_PATH       = var.media_path
  }

  secret_env = {
    PLEX_CLAIM = var.plex_claim
  }
}

# ---------------------------------------------------------------------------
# Ombi — media request management
# ---------------------------------------------------------------------------

module "ombi" {
  source = "../modules/portainer-stack"

  name         = "ombi"
  compose_path = "docker/ombi/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Gitea — self-hosted Git service
# ---------------------------------------------------------------------------

module "gitea" {
  source = "../modules/portainer-stack"

  name         = "gitea"
  compose_path = "docker/gitea/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    GITEA_DB_NAME       = var.gitea_db_name
    GITEA_DB_USER       = var.gitea_db_user
  }

  secret_env = {
    GITEA_DB_PASSWORD = var.gitea_db_password
  }
}

# ---------------------------------------------------------------------------
# Gitea Mirror — repository mirroring service
# ---------------------------------------------------------------------------

module "gitea_mirror" {
  source = "../modules/portainer-stack"

  name         = "gitea-mirror"
  compose_path = "docker/gitea-mirror/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }

  secret_env = {
    BETTER_AUTH_SECRET = var.better_auth_secret
  }
}

# ---------------------------------------------------------------------------
# Homarr — homelab dashboard
# ---------------------------------------------------------------------------

module "homarr" {
  source = "../modules/portainer-stack"

  name         = "homarr"
  compose_path = "docker/homarr/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }

  secret_env = {
    SECRET_ENCRYPTION_KEY = var.homarr_secret_encryption_key
  }
}

# ---------------------------------------------------------------------------
# Beszel — lightweight server monitoring hub
# ---------------------------------------------------------------------------

module "beszel" {
  source = "../modules/portainer-stack"

  name         = "beszel"
  compose_path = "docker/beszel/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    BESZEL_PUBLIC_KEY   = var.beszel_public_key
    DOCKER_BASE_PATH    = var.docker_base_path
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Zerobyte — backup management
# ---------------------------------------------------------------------------

module "zerobyte" {
  source = "../modules/portainer-stack"

  name         = "zerobyte"
  compose_path = "docker/zerobyte/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    BASE_URL            = local.zerobyte_base_url
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }

  secret_env = {
    APP_SECRET = var.zerobyte_app_secret
  }
}

# ---------------------------------------------------------------------------
# IT Tools — developer utilities
# ---------------------------------------------------------------------------

module "it_tools" {
  source = "../modules/portainer-stack"

  name         = "it-tools"
  compose_path = "docker/it-tools/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
  }
}

# ---------------------------------------------------------------------------
# Stirling PDF — PDF manipulation toolkit
# ---------------------------------------------------------------------------

module "stirling_pdf" {
  source = "../modules/portainer-stack"

  name         = "stirling-pdf"
  compose_path = "docker/stirling-pdf/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH                   = var.docker_base_path
    DOCKER_ENABLE_SECURITY             = "true"
    SECURITY_ENABLELOGIN               = "true"
    SECURITY_INITIALLOGIN_USERNAME     = var.stirling_security_initiallogin_username
    SECURITY_CSRFDISABLED              = var.stirling_csrf_disabled
    INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "false"
    METRICS_ENABLED                    = "true"
    PUID                               = local.puid_str
    PGID                               = local.pgid_str
    SYSTEM_DEFAULTLOCALE               = "en-US"
    SYSTEM_MAXFILESIZE                 = "2000"
    SYSTEM_GOOGLEVISIBILITY            = "false"
    TRAEFIK_BASE_DOMAIN                = var.traefik_base_domain
  }

  secret_env = {
    SECURITY_INITIALLOGIN_PASSWORD = var.stirling_security_initiallogin_password
  }
}

# ---------------------------------------------------------------------------
# MeTube — yt-dlp web interface
# ---------------------------------------------------------------------------

module "metube" {
  source = "../modules/portainer-stack"

  name         = "metube"
  compose_path = "docker/metube/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    OUTPUT_TEMPLATE     = var.metube_output_template
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    UMASK               = "002"
    YTDL_OPTIONS        = var.metube_ytdl_options
    MEDIA_PATH          = var.media_path
    DOCKER_BASE_PATH    = var.docker_base_path
  }
}

# ---------------------------------------------------------------------------
# HandBrake — video transcoder with GPU acceleration
# ---------------------------------------------------------------------------

module "handbrake" {
  source = "../modules/portainer-stack"

  name         = "handbrake"
  compose_path = "docker/handbrake/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    UMASK               = "0022"
    MEDIA_PATH          = var.media_path
    BACKUP_PATH         = var.backup_path
  }
}

# ---------------------------------------------------------------------------
# NetbootXYZ — network boot service
# ---------------------------------------------------------------------------

module "netbootxyz" {
  source = "../modules/portainer-stack"

  name                  = "netbootxyz"
  compose_path          = "docker/netbootxyz/docker-compose.yml"
  endpoint_id           = var.portainer_endpoint_id
  repo_url              = var.repo_url
  tz                    = var.tz
  support_relative_path = true

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    NGINX_PORT          = "80"
    PUID                = local.puid_str
    PGID                = local.pgid_str
    TRAEFIK_BASE_DOMAIN = var.traefik_base_domain
    WEB_APP_PORT        = "3000"
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

module "rackula" {
  source = "../modules/portainer-stack"

  name         = "rackula"
  compose_path = "docker/rackula/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH                   = var.docker_base_path
    PUID                               = local.puid_str
    PGID                               = local.pgid_str
    TRAEFIK_BASE_DOMAIN                = var.traefik_base_domain
    RACKULA_API_PORT                   = var.rackula_api_port
    RACKULA_AUTH_MODE                  = var.rackula_auth_mode
    RACKULA_LOCAL_USERNAME             = var.rackula_local_username
    RACKULA_AUTH_SESSION_COOKIE_SECURE = "true"
    ALLOW_INSECURE_CORS                = "false"
  }

  secret_env = {
    RACKULA_API_WRITE_TOKEN     = var.rackula_api_write_token
    RACKULA_AUTH_SESSION_SECRET = var.rackula_auth_session_secret
    RACKULA_LOCAL_PASSWORD      = var.rackula_local_password
  }
}

# ---------------------------------------------------------------------------
# Code-Server — browser-based VS Code with Tailscale integration
# ---------------------------------------------------------------------------

module "code_server" {
  source = "../modules/portainer-stack"

  name                  = "code-server"
  compose_path          = "docker/code-server/docker-compose.yml"
  endpoint_id           = var.portainer_endpoint_id
  repo_url              = var.repo_url
  tz                    = var.tz
  support_relative_path = true

  env = {
    PUID              = local.puid_str
    PGID              = local.pgid_str
    DEFAULT_WORKSPACE = var.code_server_default_workspace
    TS_EXTRA_ARGS     = var.code_server_ts_extra_args
    TS_SERVE_CONFIG   = "/config/code-server.json"
    TS_SOCKET         = "/var/run/tailscale/tailscaled.sock"
    TS_STATE_DIR      = "/var/lib/tailscale"
    TS_USERSPACE      = "false"
  }

  secret_env = {
    PASSWORD      = var.code_server_password
    SUDO_PASSWORD = var.code_server_sudo_password
    TS_AUTHKEY    = var.code_server_ts_authkey
  }
}

# ---------------------------------------------------------------------------
# Watchtower — automated container image updates
# ---------------------------------------------------------------------------

module "watchtower" {
  source = "../modules/portainer-stack"

  name         = "watchtower"
  compose_path = "docker/watchtower/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    WATCHTOWER_CLEANUP = var.watchtower_cleanup
  }
}

# ---------------------------------------------------------------------------
# Netdata — real-time system monitoring (deployed to dh01 and dh02)
# Uses host networking for deep system and Docker monitoring.
# Both nodes auto-register to Netdata Cloud using their system hostname.
# ---------------------------------------------------------------------------

module "netdata_dh01" {
  source = "../modules/portainer-stack"

  name         = "netdata"
  compose_path = "docker/netdata/docker-compose.yml"
  endpoint_id  = var.dh01_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    NETDATA_CLAIM_URL   = var.netdata_claim_url
    NETDATA_CLAIM_ROOMS = var.netdata_claim_rooms
  }

  secret_env = {
    NETDATA_CLAIM_TOKEN = var.netdata_claim_token
  }
}

module "netdata_dh02" {
  source = "../modules/portainer-stack"

  name         = "netdata"
  compose_path = "docker/netdata/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH    = var.docker_base_path
    NETDATA_CLAIM_URL   = var.netdata_claim_url
    NETDATA_CLAIM_ROOMS = var.netdata_claim_rooms
  }

  secret_env = {
    NETDATA_CLAIM_TOKEN = var.netdata_claim_token
  }
}

# ---------------------------------------------------------------------------
# Mail Archiver — email archiving with IMAP/M365 sync and advanced search
# ---------------------------------------------------------------------------

module "mail_archiver" {
  source = "../modules/portainer-stack"

  name         = "mail-archiver"
  compose_path = "docker/mail-archiver/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH         = var.docker_base_path
    TRAEFIK_BASE_DOMAIN      = var.traefik_base_domain
    MAIL_ARCHIVER_ADMIN_USER = var.mail_archiver_admin_user
    MAIL_ARCHIVER_DB_NAME    = var.mail_archiver_db_name
    MAIL_ARCHIVER_DB_USER    = var.mail_archiver_db_user
  }

  secret_env = {
    MAIL_ARCHIVER_ADMIN_PASSWORD = var.mail_archiver_admin_password
    MAIL_ARCHIVER_DB_PASSWORD    = var.mail_archiver_db_password
  }
}

# ---------------------------------------------------------------------------
# AzerothCore — WotLK test realm (local build stack; image built on the host)
# ---------------------------------------------------------------------------

module "azerothcore" {
  source = "../modules/portainer-stack"

  name         = "azerothcore"
  compose_path = "docker/azerothcore/docker-compose.yml"
  endpoint_id  = var.portainer_endpoint_id
  repo_url     = var.repo_url
  tz           = var.tz

  env = {
    DOCKER_BASE_PATH      = var.docker_base_path
    PUID                  = local.puid_str
    PGID                  = local.pgid_str
    AC_REF                = var.azerothcore_ref
    MOD_GUILD_DISCORD_REF = var.azerothcore_mod_guild_discord_ref
  }

  secret_env = {
    AZEROTHCORE_DB_ROOT_PASSWORD          = var.azerothcore_db_root_password
    AZEROTHCORE_DISCORD_TOKEN             = var.azerothcore_discord_token
    AZEROTHCORE_DISCORD_RELAY_DB_PASSWORD = var.azerothcore_discord_relay_db_password
  }
}

# ---------------------------------------------------------------------------
# State migration from standalone portainer_stack resources
# ---------------------------------------------------------------------------

moved {
  from = portainer_stack.traefik
  to   = module.traefik.portainer_stack.this
}

moved {
  from = portainer_stack.home_assistant
  to   = module.home_assistant.portainer_stack.this
}

moved {
  from = portainer_stack.plex
  to   = module.plex.portainer_stack.this
}

moved {
  from = portainer_stack.ombi
  to   = module.ombi.portainer_stack.this
}

moved {
  from = portainer_stack.gitea
  to   = module.gitea.portainer_stack.this
}

moved {
  from = portainer_stack.gitea_mirror
  to   = module.gitea_mirror.portainer_stack.this
}

moved {
  from = portainer_stack.homarr
  to   = module.homarr.portainer_stack.this
}

moved {
  from = portainer_stack.beszel
  to   = module.beszel.portainer_stack.this
}

moved {
  from = portainer_stack.zerobyte
  to   = module.zerobyte.portainer_stack.this
}

moved {
  from = portainer_stack.it_tools
  to   = module.it_tools.portainer_stack.this
}

moved {
  from = portainer_stack.stirling_pdf
  to   = module.stirling_pdf.portainer_stack.this
}

moved {
  from = portainer_stack.metube
  to   = module.metube.portainer_stack.this
}

moved {
  from = portainer_stack.handbrake
  to   = module.handbrake.portainer_stack.this
}

moved {
  from = portainer_stack.netbootxyz
  to   = module.netbootxyz.portainer_stack.this
}

moved {
  from = portainer_stack.rackula
  to   = module.rackula.portainer_stack.this
}

moved {
  from = portainer_stack.code_server
  to   = module.code_server.portainer_stack.this
}

moved {
  from = portainer_stack.watchtower
  to   = module.watchtower.portainer_stack.this
}

moved {
  from = portainer_stack.netdata_dh01
  to   = module.netdata_dh01.portainer_stack.this
}

moved {
  from = portainer_stack.netdata_dh02
  to   = module.netdata_dh02.portainer_stack.this
}

moved {
  from = portainer_stack.mail_archiver
  to   = module.mail_archiver.portainer_stack.this
}
