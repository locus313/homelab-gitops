terraform {
  required_version = ">= 1.0"

  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "~> 1.29"
    }
  }
}

provider "portainer" {
  endpoint        = var.portainer_endpoint
  api_key         = var.portainer_api_key
  skip_ssl_verify = var.skip_ssl_verify
}
