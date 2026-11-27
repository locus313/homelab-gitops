# ---------------------------------------------------------------------------
# Locals — computed values shared across multiple stacks
# ---------------------------------------------------------------------------

locals {
  # String-typed user/group IDs for env blocks (Portainer env values are strings)
  puid_str = tostring(var.puid)
  pgid_str = tostring(var.pgid)
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
# iVentoy — ISO network boot server
# Not currently deployed (conflicts with NetbootXYZ on port 69/udp TFTP).
# To enable: uncomment and remove the port 69 line from docker/iventoy/docker-compose.yml,
# or accept that TFTP won't be available for iVentoy clients.
#
# resource "portainer_stack" "iventoy" { ... }
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Netdata — real-time system monitoring on dh01
# Uses host networking for deep system and Docker monitoring.
# Both nodes auto-register to Netdata Cloud using their system hostname.
# ---------------------------------------------------------------------------

module "netdata_dh01" {
  count  = var.keep_netdata_dh01 ? 1 : 0
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

moved {
  from = module.netdata_dh01
  to   = module.netdata_dh01[0]
}
