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
  description = "Path on dh02 for MeTube download storage"
  type        = string
  default     = "/mnt/media"
}

variable "enable_pilot" {
  description = "Create and start the isolated Arcane pilot on the local Docker host"
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
  description = "Group ID for Ombi and MeTube container file ownership"
  type        = number
  default     = 1000
}

variable "pilot_value" {
  description = "Non-secret marker used to verify pilot environment propagation"
  type        = string
  default     = "terraform-managed"
}

variable "puid" {
  description = "User ID for Ombi and MeTube container file ownership"
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
