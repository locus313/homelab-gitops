terraform {
  required_version = ">= 1.3"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
