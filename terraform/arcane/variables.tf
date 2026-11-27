variable "arcane_endpoint" {
  description = "Arcane API URL, including /api"
  type        = string
}

variable "docker_base_path" {
  description = "Base path for persistent service data on dh02"
  type        = string
  default     = "/docker"
}

variable "media_path" {
  description = "Path on dh02 for Plex, MeTube, and HandBrake media"
  type        = string
  default     = "/mnt/media"
}

variable "backup_path" {
  description = "Path on dh02 for HandBrake backup storage"
  type        = string
  default     = "/mnt/backups"
}

variable "enable_pilot" {
  description = "Create and start the isolated Arcane pilot on the local Docker host"
  type        = bool
  default     = false
}

variable "enable_handbrake" {
  description = "Create and start HandBrake on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_netbootxyz" {
  description = "Create and start NetbootXYZ on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_beszel" {
  description = "Create and start Beszel on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_it_tools" {
  description = "Create and start IT Tools on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_metube" {
  description = "Create and start MeTube on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_ombi" {
  description = "Create and start Ombi on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_home_assistant" {
  description = "Create and start Home Assistant on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_netdata" {
  description = "Create and start Netdata on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_watchtower" {
  description = "Create and start Watchtower on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_stirling_pdf" {
  description = "Create and start Stirling PDF on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_gitea_mirror" {
  description = "Create and start Gitea Mirror on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_gitea" {
  description = "Create and start Gitea on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_homarr" {
  description = "Create and start Homarr on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_rackula" {
  description = "Create and start Rackula on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_hermes_agent" {
  description = "Create and start Hermes Agent on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_mail_archiver" {
  description = "Create and start Mail Archiver on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_plex" {
  description = "Create and start Plex on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_code_server" {
  description = "Create and start Code Server on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_azerothcore" {
  description = "Create and start AzerothCore on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_zerobyte" {
  description = "Create and start Zerobyte on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "enable_traefik" {
  description = "Create and start Traefik on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "watchtower_cleanup" {
  description = "Remove old images after Watchtower container updates"
  type        = string
  default     = "true"
}

variable "stirling_security_initiallogin_username" {
  description = "Initial admin username for Stirling PDF"
  type        = string
  default     = "admin"
}

variable "stirling_security_initiallogin_password" {
  description = "Initial admin password for Stirling PDF"
  type        = string
  sensitive   = true
}

variable "stirling_csrf_disabled" {
  description = "Disable CSRF protection in Stirling PDF"
  type        = string
  default     = "false"
}

variable "better_auth_secret" {
  description = "Better Auth secret key for Gitea Mirror session signing and token encryption"
  type        = string
  sensitive   = true
}

variable "gitea_db_name" {
  description = "Gitea PostgreSQL database name"
  type        = string
  default     = "gitea"
}

variable "gitea_db_password" {
  description = "Gitea PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "gitea_db_user" {
  description = "Gitea PostgreSQL database user"
  type        = string
  default     = "gitea"
}

variable "homarr_secret_encryption_key" {
  description = "32-character hex key for Homarr data encryption"
  type        = string
  sensitive   = true
}

variable "rackula_api_write_token" {
  description = "Bearer token for Rackula write API access"
  type        = string
  sensitive   = true
}

variable "rackula_auth_session_secret" {
  description = "Secret for Rackula session signing"
  type        = string
  default     = ""
  sensitive   = true
}

variable "rackula_local_password" {
  description = "Password for the Rackula local admin account"
  type        = string
  sensitive   = true
}

variable "rackula_auth_mode" {
  description = "Rackula authentication mode"
  type        = string
  default     = "none"
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

variable "hermes_trusted_proxy" {
  description = "Traefik container IPv4 address on proxynet; update after it changes"
  type        = string

  validation {
    condition     = length(split(".", var.hermes_trusted_proxy)) == 4 && can(cidrhost("${var.hermes_trusted_proxy}/32", 0))
    error_message = "Set hermes_trusted_proxy to a single IPv4 address."
  }
}

variable "hermes_dashboard_username" {
  description = "Hermes dashboard login username"
  type        = string
}

variable "hermes_dashboard_password" {
  description = "Hermes dashboard login password"
  type        = string
  sensitive   = true
}

variable "hermes_discord_bot_token" {
  description = "Hermes Discord bot token"
  type        = string
  sensitive   = true
}

variable "hermes_discord_allowed_users" {
  description = "Comma-separated Discord user IDs authorized to use Hermes"
  type        = string
}

variable "mail_archiver_admin_user" {
  description = "Mail Archiver initial admin username"
  type        = string
  default     = "admin"
}

variable "mail_archiver_admin_password" {
  description = "Mail Archiver initial admin password"
  type        = string
  sensitive   = true
}

variable "mail_archiver_db_name" {
  description = "Mail Archiver PostgreSQL database name"
  type        = string
  default     = "mailarchiver"
}

variable "mail_archiver_db_user" {
  description = "Mail Archiver PostgreSQL database user"
  type        = string
  default     = "mailuser"
}

variable "mail_archiver_db_password" {
  description = "Mail Archiver PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "plex_claim" {
  description = "Plex claim token for server registration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "code_server_password" {
  description = "Password for the Code Server web interface"
  type        = string
  sensitive   = true
}

variable "code_server_sudo_password" {
  description = "Sudo password for terminal access within Code Server"
  type        = string
  sensitive   = true
}

variable "code_server_default_workspace" {
  description = "Default workspace directory inside Code Server"
  type        = string
  default     = "/config/workspace"
}

variable "code_server_ts_authkey" {
  description = "Tailscale auth key for the Code Server sidecar"
  type        = string
  sensitive   = true
}

variable "code_server_ts_extra_args" {
  description = "Extra arguments for the Code Server Tailscale sidecar"
  type        = string
  default     = "--advertise-tags=tag:container --reset"
}

variable "azerothcore_ref" {
  description = "AzerothCore commit SHA the local image was built from"
  type        = string
  default     = "d5e818f28ee80f5a39115c3bbaa695a6f859303e"
}

variable "azerothcore_mod_guild_discord_ref" {
  description = "mod-guild-discord branch, tag, or commit to build"
  type        = string
  default     = "master"
}

variable "azerothcore_db_root_password" {
  description = "AzerothCore MySQL root password"
  type        = string
  sensitive   = true
}

variable "azerothcore_discord_token" {
  description = "Discord bot token for the AzerothCore discord-relay sidecar"
  type        = string
  sensitive   = true
}

variable "azerothcore_discord_relay_db_password" {
  description = "Password of the discord_relay MySQL account used by the sidecar"
  type        = string
  sensitive   = true
}

variable "zerobyte_app_secret" {
  description = "Existing secret for decrypting Zerobyte database data"
  type        = string
  sensitive   = true
}

variable "beszel_public_key" {
  description = "Ed25519 public key for Beszel agent authentication; use the existing value from terraform/portainer/.envrc"
  type        = string
  default     = ""
}

variable "netdata_claim_rooms" {
  description = "Netdata Cloud room ID(s) to add dh02 to"
  type        = string
  default     = ""
}

variable "netdata_claim_token" {
  description = "Netdata Cloud claim token for registering dh02"
  type        = string
  sensitive   = true
}

variable "netdata_claim_url" {
  description = "Netdata Cloud claim URL"
  type        = string
  default     = "https://app.netdata.cloud"
}

variable "metube_output_template" {
  description = "yt-dlp output filename template for MeTube downloads"
  type        = string
  default     = "YouTube.com - %(title)s.%(ext)s"
}

variable "metube_ytdl_options" {
  description = "Additional yt-dlp options for MeTube as a JSON string"
  type        = string
  default     = "{}"
}

variable "pgid" {
  description = "Group ID for Gitea, HandBrake, Home Assistant, MeTube, NetbootXYZ, Ombi, and Plex container file ownership"
  type        = number
  default     = 1000
}

variable "pilot_value" {
  description = "Non-secret marker used to verify pilot environment propagation"
  type        = string
  default     = "terraform-managed"
}

variable "puid" {
  description = "User ID for Gitea, HandBrake, Home Assistant, MeTube, NetbootXYZ, Ombi, and Plex container file ownership"
  type        = number
  default     = 1000
}

variable "repo_url" {
  description = "Public Git repository URL for the pilot"
  type        = string
  default     = "https://github.com/locus313/homelab-gitops"
}

variable "traefik_base_domain" {
  description = "Base domain used by Traefik for service routing"
  type        = string
}

variable "nas_ip" {
  description = "IP address of the NAS used by Traefik dynamic configuration"
  type        = string
}

variable "cloudns_propagation_timeout" {
  description = "Seconds to wait for CloudNS DNS TXT record propagation"
  type        = string
  default     = "600"
}

variable "cloudns_sub_auth_id" {
  description = "CloudNS sub-auth ID for Traefik DNS-01 challenges"
  type        = string
  sensitive   = true
}

variable "cloudns_auth_password" {
  description = "CloudNS auth password for Traefik DNS-01 challenges"
  type        = string
  sensitive   = true
}
