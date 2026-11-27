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
  description = "Path on dh02 for MeTube downloads and HandBrake media"
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

variable "watchtower_cleanup" {
  description = "Remove old images after Watchtower container updates"
  type        = string
  default     = "true"
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
  description = "Group ID for HandBrake, Home Assistant, MeTube, NetbootXYZ, and Ombi container file ownership"
  type        = number
  default     = 1000
}

variable "pilot_value" {
  description = "Non-secret marker used to verify pilot environment propagation"
  type        = string
  default     = "terraform-managed"
}

variable "puid" {
  description = "User ID for HandBrake, Home Assistant, MeTube, NetbootXYZ, and Ombi container file ownership"
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
