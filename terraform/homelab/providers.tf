terraform {
  required_providers {
    hypercore = {
      source  = "ScaleComputing/hypercore"
      version = "1.4.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "hypercore" {}

# Authentication via environment variables (set in .envrc):
#   PROXMOX_VE_ENDPOINT       — e.g. "https://pve01.home.lan:8006"
#   PROXMOX_VE_API_TOKEN      — e.g. "root@pam!terraform=<token-secret>"
#   PROXMOX_VE_INSECURE       — "true" to skip TLS verification (self-signed cert)
#   PROXMOX_VE_SSH_USERNAME   — SSH user for node operations (typically "root")
#   PROXMOX_VE_SSH_PASSWORD   — SSH password for the above user
provider "proxmox" {
  ssh {
    agent = false
  }
}
