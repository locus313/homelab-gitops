terraform {
  required_providers {
    hypercore = {
      source  = "ScaleComputing/hypercore"
      version = "1.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "hypercore" {
}
