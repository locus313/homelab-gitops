terraform {
  required_providers {
    hypercore = {
      source = "ScaleComputing/hypercore"
      version = "1.1.0"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
}

provider "hypercore" {
}
