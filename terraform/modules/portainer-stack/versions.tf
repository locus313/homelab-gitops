# Terraform and Provider Version Requirements

terraform {
  required_version = ">= 1.0"

  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "~> 2.0"
    }
  }
}
