variable "name" {
  description = "Portainer stack name"
  type        = string
}

variable "compose_path" {
  description = "Path to the compose file within the repository (e.g. docker/plex/docker-compose.yml)"
  type        = string
}

variable "endpoint_id" {
  description = "Portainer environment/endpoint ID to deploy the stack to"
  type        = number
}

variable "repo_url" {
  description = "Git repository URL for GitOps stack deployment"
  type        = string
}

variable "tz" {
  description = "Timezone injected into every stack as TZ"
  type        = string
}

variable "env" {
  description = "Non-secret environment variables for the stack"
  type        = map(string)
  default     = {}
}

variable "secret_env" {
  description = "Secret environment variables for the stack (kept redacted in plans)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "support_relative_path" {
  description = "Let Portainer keep the stack directory synced to the host so relative bind mounts resolve"
  type        = bool
  default     = false
}

variable "filesystem_path" {
  description = "Host path Portainer syncs the stack directory to (used with support_relative_path)"
  type        = string
  default     = null
}
