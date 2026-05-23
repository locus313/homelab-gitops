# ---------------------------------------------------------------------------
# Portainer connection
# ---------------------------------------------------------------------------

variable "portainer_endpoint" {
  description = "URL to the Portainer API (e.g. https://portainer.example.com)"
  type        = string
}

variable "portainer_api_key" {
  description = "Portainer API key (generate in Portainer UI: Account → Access tokens)"
  type        = string
  sensitive   = true
}

variable "portainer_endpoint_id" {
  description = "Portainer environment/endpoint ID to deploy stacks to (local = 1, i.e. dh02)"
  type        = number
  default     = 1
}

variable "dh01_endpoint_id" {
  description = "Portainer environment/endpoint ID for dh01 (registered Portainer agent)"
  type        = number
}

variable "skip_ssl_verify" {
  description = "Skip TLS certificate verification for Portainer connection"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Git repository
# ---------------------------------------------------------------------------

variable "repo_url" {
  description = "Git repository URL for GitOps stack deployments"
  type        = string
  default     = "https://github.com/locus313/homelab-gitops.git"
}

variable "repo_base_path" {
  description = "Absolute path on the Docker host where the cloud-init repo clone lives (bootstrap only — not updated by Portainer)"
  type        = string
  default     = "/opt/homelab-gitops"
}

variable "portainer_stack_path" {
  description = "Base path on the Docker host where Portainer stores synced stack files for relative bind mounts. Must be outside repo_base_path to avoid git-within-git conflicts."
  type        = string
  default     = "/opt/portainer-stacks"
}

# ---------------------------------------------------------------------------
# Common stack variables
# ---------------------------------------------------------------------------

variable "traefik_base_domain" {
  description = "Base domain used by Traefik for service routing (e.g. example.com)"
  type        = string
}

variable "docker_base_path" {
  description = "Base path on the Docker host for persistent service data"
  type        = string
  default     = "/mnt/docker"
}

variable "tz" {
  description = "Timezone for all services"
  type        = string
  default     = "America/Los_Angeles"
}

variable "puid" {
  description = "User ID for file ownership in containers"
  type        = number
  default     = 1000
}

variable "pgid" {
  description = "Group ID for file ownership in containers"
  type        = number
  default     = 1000
}

variable "media_path" {
  description = "Path on the Docker host for media library (NFS mount)"
  type        = string
  default     = "/mnt/media"
}

variable "nas_ip" {
  description = "IP address of the NAS (used in Traefik dynamic config)"
  type        = string
}

# ---------------------------------------------------------------------------
# Traefik / CloudNS
# ---------------------------------------------------------------------------

variable "cloudns_sub_auth_id" {
  description = "CloudNS sub-auth ID for DNS-01 certificate challenge"
  type        = string
  sensitive   = true
}

variable "cloudns_auth_password" {
  description = "CloudNS auth password for DNS-01 certificate challenge"
  type        = string
  sensitive   = true
}

variable "cloudns_propagation_timeout" {
  description = "Seconds to wait for DNS TXT record propagation (CloudNS lego provider default is only 120s)"
  type        = string
  default     = "600"
}

# ---------------------------------------------------------------------------
# Portainer EE license
# ---------------------------------------------------------------------------

variable "portainer_license_key" {
  description = "Portainer Business Edition license key"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Gitea
# ---------------------------------------------------------------------------

variable "gitea_db_name" {
  description = "Gitea PostgreSQL database name"
  type        = string
  default     = "gitea"
}

variable "gitea_db_user" {
  description = "Gitea PostgreSQL database user"
  type        = string
  default     = "gitea"
}

variable "gitea_db_password" {
  description = "Gitea PostgreSQL database password"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Gitea Mirror
# ---------------------------------------------------------------------------

variable "better_auth_secret" {
  description = "Secret key for Gitea Mirror BetterAuth session signing (min 32 chars)"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Homarr
# ---------------------------------------------------------------------------

variable "homarr_secret_encryption_key" {
  description = "32-character hex key for Homarr data encryption"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Beszel
# ---------------------------------------------------------------------------

variable "beszel_public_key" {
  description = "Ed25519 public key for Beszel agent authentication (generated on first run). Leave empty on first deploy — get the key from the Beszel hub UI after it starts, then re-apply."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Zerobyte
# ---------------------------------------------------------------------------

variable "zerobyte_app_secret" {
  description = "Secret for encrypting Zerobyte database data (v0.23+)"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Plex
# ---------------------------------------------------------------------------

variable "plex_claim" {
  description = "Plex claim token for server registration (claim.plex.tv — expires quickly, optional after initial setup)"
  type        = string
  default     = ""
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Stirling-PDF
# ---------------------------------------------------------------------------

variable "stirling_security_initiallogin_username" {
  description = "Initial admin username for Stirling-PDF"
  type        = string
  default     = "admin"
}

variable "stirling_security_initiallogin_password" {
  description = "Initial admin password for Stirling-PDF"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# MeTube
# ---------------------------------------------------------------------------

variable "metube_output_template" {
  description = "yt-dlp output filename template for MeTube downloads"
  type        = string
  default     = "YouTube.com - %(title)s.%(ext)s"
}

variable "metube_ytdl_options" {
  description = "Additional yt-dlp options as JSON string"
  type        = string
  default     = "{}"
}

# ---------------------------------------------------------------------------
# HandBrake
# ---------------------------------------------------------------------------

variable "backup_path" {
  description = "Path on the Docker host for backup storage (used by HandBrake)"
  type        = string
  default     = "/mnt/backups"
}

# ---------------------------------------------------------------------------
# Rackula
# ---------------------------------------------------------------------------

variable "rackula_api_write_token" {
  description = "Bearer token for Rackula write API access"
  type        = string
  sensitive   = true
}

variable "rackula_local_password" {
  description = "Password for the Rackula local admin account"
  type        = string
  sensitive   = true
}

variable "rackula_auth_session_secret" {
  description = "Secret for Rackula session signing (leave empty if auth_mode is none)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "rackula_local_username" {
  description = "Username for the Rackula local admin account"
  type        = string
  default     = "admin"
}

variable "rackula_api_port" {
  description = "Port for the Rackula API server"
  type        = string
  default     = "3001"
}

variable "rackula_auth_mode" {
  description = "Rackula authentication mode (none, local)"
  type        = string
  default     = "none"
}

# ---------------------------------------------------------------------------
# Watchtower
# ---------------------------------------------------------------------------

variable "watchtower_cleanup" {
  description = "Remove old images after container updates"
  type        = string
  default     = "true"
}

# ---------------------------------------------------------------------------
# Code-Server
# ---------------------------------------------------------------------------

variable "code_server_password" {
  description = "Password for the code-server web interface"
  type        = string
  sensitive   = true
}

variable "code_server_sudo_password" {
  description = "Sudo password for terminal access within code-server"
  type        = string
  sensitive   = true
}

variable "code_server_default_workspace" {
  description = "Default workspace directory inside code-server"
  type        = string
  default     = "/config/workspace"
}

variable "code_server_ts_authkey" {
  description = "Tailscale auth key for the code-server Tailscale sidecar"
  type        = string
  sensitive   = true
}

variable "code_server_ts_extra_args" {
  description = "Extra arguments for the Tailscale sidecar (e.g. --advertise-tags)"
  type        = string
  default     = "--advertise-tags=tag:container --reset"
}

# ---------------------------------------------------------------------------
# Netdata
# ---------------------------------------------------------------------------

variable "netdata_claim_token" {
  description = "Netdata Cloud claim token for node registration (from app.netdata.cloud)"
  type        = string
  sensitive   = true
}

variable "netdata_claim_url" {
  description = "Netdata Cloud claim URL"
  type        = string
  default     = "https://app.netdata.cloud"
}

variable "netdata_claim_rooms" {
  description = "Netdata Cloud room ID(s) to add nodes to"
  type        = string
  default     = ""
}
