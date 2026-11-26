variable "arcane_endpoint" {
  description = "Arcane API URL, including /api"
  type        = string
}

variable "docker_base_path" {
  description = "Base path for persistent service data on dh02"
  type        = string
  default     = "/docker"
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

variable "enable_ombi" {
  description = "Create and start Ombi on dh02 after removing its Portainer stack"
  type        = bool
  default     = false
}

variable "pgid" {
  description = "Group ID for Ombi container file ownership"
  type        = number
  default     = 1000
}

variable "pilot_value" {
  description = "Non-secret marker used to verify pilot environment propagation"
  type        = string
  default     = "terraform-managed"
}

variable "puid" {
  description = "User ID for Ombi container file ownership"
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
