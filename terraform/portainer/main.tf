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
# iVentoy — ISO network boot server
# Not currently deployed (conflicts with NetbootXYZ on port 69/udp TFTP).
# To enable: uncomment and remove the port 69 line from docker/iventoy/docker-compose.yml,
# or accept that TFTP won't be available for iVentoy clients.
#
# resource "portainer_stack" "iventoy" { ... }
# ---------------------------------------------------------------------------

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
  from = portainer_stack.ombi
  to   = module.ombi.portainer_stack.this
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
  from = portainer_stack.netdata_dh01
  to   = module.netdata_dh01.portainer_stack.this
}
