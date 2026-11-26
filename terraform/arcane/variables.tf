variable "arcane_endpoint" {
  description = "Arcane API URL, including /api"
  type        = string
}

variable "enable_pilot" {
  description = "Create and start the isolated Arcane pilot on the local Docker host"
  type        = bool
  default     = false
}

variable "pilot_value" {
  description = "Non-secret marker used to verify pilot environment propagation"
  type        = string
  default     = "terraform-managed"
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
