terraform {
  required_providers {
    hypercore = {
      source  = "ScaleComputing/hypercore"
      version = "1.1.0"
    }
  }
}

provider "hypercore" {
}
